module Seek

  class ParserMapper


    # how to define a new parser mapping with name NEW_MAPPER
    # * create a private method NEW_MAPPER_mapping
    # * copy the hash from empty mapping to NEW_MAPPER_mapping
    # * specify data like :name, :data_offset, :probing_column etc...
    # * fill in your mapped fields
    # ** see existing mappings for examples for using different blocks to handle FIXED-data columns
    # ** or columns that share some raw data that has be extracted by a regular expression
    # * (OPTIONAL) define a (filename-pattern-to-parser-mapping-name)-mapping in filename_to_mapping_name to enable automatic detection of parser mappings by filename

    def initialize
    end

    # returns a mapping given a mapping name (convention: name of method without "_mapping")
    def mapping mapping_name
      mapping = self.send(mapping_name+"_mapping")
      if mapping
        if check_mapping mapping
          return mapping
        end

        nil

      else
        nil

      end

    end

    # this method defines a (filename-pattern-to-parser-mapping-name)-mapping
    # to add a mapping just add a when clause relating a file pattern to the name of the parser-mapping (without "_mapping")
    def filename_to_mapping_name filename
      case filename
        when /^jena.*/i then "jena"
        when /^do_hengstler.*/i then "dortmund_hengstler"
        when /^do_bcat_ko.*/i then "dortmund_bcat_ko"
        when /^due_bode.*/i then "duesseldorf_bode"
        else "unknown"
      end
    end


    private

    def check_mapping mapping      #TODO check whether all necessary fields are mapped
      true
    end

    # the default mapping entry
    # if no block is specified a simple block is defined that just returns the input
    def mapping_entry column_name, block=nil
      unless block
        block = proc { |data| data}
      end

      {:column => column_name, :value => block}
    end

    # mapping for jena excel sheets
    # example file: jenage-excel_template-without-protection correct.xlsm
    def jena_mapping
      {
          :name => "jena",
          :data_row_offset => 2,



          :samples_mapping => {

              :samples_sheet_name => "SDRF",

              :add_specimens => true,
              :add_treatments => true,
              :add_samples => true,

              :probing_column => :"specimens.title",


              :"organisms.title" => mapping_entry("Organism"),

              :"strains.title" => mapping_entry("Strain or Line"),

              :"specimens.sex" => mapping_entry("Sex"),
              :"specimens.title" => mapping_entry("# Specimen"),
              :"specimens.lab_internal_number" => mapping_entry("# Specimen"),
              :"specimens.age" => mapping_entry("Age"),
              :"specimens.age_unit" => mapping_entry("Age Time Unit"),
              :"specimens.comments" => mapping_entry("FIXED", proc {""}),
              :"specimens.genotype.title" => mapping_entry("FIXED", proc {"none"}),
              :"specimens.genotype.modification" => mapping_entry("FIXED", proc{""}),

              :"treatment.treatment_protocol" => mapping_entry("Treatment Protocol"),
              :"treatment.substance" => mapping_entry("Substance"),
              :"treatment.concentration" => mapping_entry("Concentration"),
              :"treatment.unit" => mapping_entry("Unit"),

              :"samples.comments" => mapping_entry("Additional Information"),
              :"samples.title" => mapping_entry("Sample Name"),
              :"samples.sample_type" => mapping_entry("Material Type"),
              :"samples.donation_date" => mapping_entry("Storage Date", proc  {|data| data != "" ? data : Time.now}), # the default value is certainly wrong -- but we need some donation_date

              :"tissue_and_cell_types.title" => mapping_entry("Organism Part"),

              :"sop.title" => mapping_entry("Storage Protocol"),
              :"institution.name" => mapping_entry("Storage Location")


          },

          :assay_mapping => {

              :assay_sheet_name => "IDF",

              :"investigation.title" => mapping_entry("Investigation Title"),
              :"assay_type.title" => mapping_entry("Experiment Class"),
              :"study.title" => mapping_entry("Experiment Description"),

              :"creator.email" => mapping_entry("Person Email"),
              :"creator.last_name" => mapping_entry("Person Last Name"),
              :"creator.first_name" => mapping_entry("Person First Name")

          }



      }

    end

    # mapping for dortmund excel sheets (I)
    # example file: do_hengstler_Sample Data Hengstler_corrected.xls
    def dortmund_hengstler_mapping

      age_regex = /(\d+-?\d*)\s*(day|week|month|year)s?/i
      treatment_regex = /(\d*\.?\d*)\s*(\w+\/\w+)\s*([\w\.\s,']*),?\s+([\w\.]*)/




      {
          :name => "dortmund_hengstler",
          :data_row_offset => 1,


          :samples_mapping => {

              :samples_sheet_name => "Tabelle1",
              :add_specimens => true,
              :add_treatments => true,
              :add_samples => true,

              :probing_column => :"specimens.title",


              :"organisms.title" => mapping_entry("FIXED", proc {"Mus musculus"}),

              :"strains.title" => mapping_entry("Mouse strain"),


              :"specimens.institution_id" => mapping_entry("Responsible Lab"),
              :"specimens.title" => mapping_entry("Lab internal number"),
              :"specimens.lab_internal_number" => mapping_entry("Lab internal number"),
              :"specimens.sex" => mapping_entry("FIXED", proc {"unknown"}),
              :"specimens.age" => mapping_entry("Age", proc do |data|
                  if data =~ age_regex
                    $1 ? $1 : ""
                  else
                    ""
                  end
              end),
              :"specimens.age_unit" => mapping_entry("Age", proc do |data|
                  if data =~ age_regex
                    $2 ? $2 : ""
                  else
                    ""
                  end
              end),




              :"specimens.donation_date" => mapping_entry("date of experiment"),
              :"specimens.comments" => mapping_entry("FIXED", proc {""}),
              :"specimens.genotype.title" => mapping_entry("FIXED", proc {"none"}),
              :"specimens.genotype.modification" => mapping_entry("FIXED", proc{""}),

              :"treatment.concentration" => mapping_entry("Treatment", proc do |data|
                if data =~ treatment_regex
                  $1 ? $1 : ""
                else
                  ""
                end
              end),
              :"treatment.unit" => mapping_entry("Treatment", proc do |data|
                if data =~ treatment_regex
                  $2 ? $2 : ""
                else
                  ""
                end
              end),
              :"treatment.substance" => mapping_entry("Treatment", proc do |data|
                if data =~ treatment_regex
                  if $3
                    substance = $3
                    if substance.end_with?(',')
                      substance.chop
                    else
                      substance
                    end
                  else
                    ""
                  end
                else
                  ""
                end
              end),
              :"treatment.treatment_protocol" => mapping_entry("Treatment", proc do |data|
                if data =~ treatment_regex
                  $4 ? $4 : ""
                else
                  ""
                end
              end),

              :"samples.comments" => mapping_entry("Comments"),
              :"samples.title" => mapping_entry("Tissue specimen no."),
              :"samples.sample_type" => mapping_entry("FIXED", proc {""}),
              :"samples.donation_date" => mapping_entry("date of experiment"),

              :"tissue_and_cell_types.title" => mapping_entry("FIXED", proc {""}),

              :"sop.title" => mapping_entry("FIXED", proc {""}),
              :"institution.name" => mapping_entry("FIXED", proc{""}),








      },

          :assay_mapping => nil



      }

    end

    # mapping for dortmund excel sheets (II)
    # example file: BCat KO sample data Dortmund.xls
    def dortmund_bcat_ko_mapping

      age_regex = /(\d+-?\d*)\s*(day|week|month|year)s?/i
      treatment_substance_regex = /.*\((control|treated)\s?=\s?(.*)\)/i
      treatment_concentration_unit_regex = /(\d*[,\.]?\d*)\s*([\w\s\/]*).*$/
      treatment_protocol_regex = /.*,\s*([\w\s\.]*)$/
      genotype_modification_regex = /(WT|KO)/

      {
          :name => "dortmund_bcat_ko",
          :data_row_offset => 1,

          :samples_mapping => {     # TODO: which fields are really necessary?
              :samples_sheet_name => "BCat KO",

              :add_specimens => true,
              :add_treatments => true,
              :add_samples => true,


              :probing_column => :"specimens.title",


              :"organisms.title" => mapping_entry("FIXED", proc {"Mus musculus"}),

              :"strains.title" => mapping_entry("FIXED", proc {"Wildtype"}),

              :"specimens.sex" => mapping_entry("Gender", proc { |data| data.downcase }),
              :"specimens.title" => mapping_entry("Sample ID"),
              :"specimens.lab_internal_number" => mapping_entry("Sample ID"),
              :"specimens.age" => mapping_entry("Age", proc do |data|
                   if data =~ age_regex
                     $1 ? $1 : ""
                   else
                     ""
                   end
              end),
              :"specimens.age_unit" => mapping_entry("Age", proc do |data|
                  if data =~ age_regex
                    $2 ? $2 : ""
                  else
                    ""
                  end
              end),
              :"specimens.comments" => mapping_entry("FIXED", proc {""}),
              :"specimens.genotype.title" => mapping_entry("FIXED", proc {"Bcat"}),
              :"specimens.genotype.modification" => mapping_entry("Genotype", proc do |data|
                  if data =~ genotype_modification_regex
                    case $1
                      when "KO" then "Knock out"
                      when "WT" then "Wildtype"
                      else "Wildtype"
                    end
                  else
                    "Wildtype"
                  end
              end),

              :"treatment.treatment_protocol" => mapping_entry("Dose/route of adminstration", proc do |data|         # sic!?
                if data =~ treatment_protocol_regex
                  $1 ? $1 : ""
                else
                  ""
                end
              end),
              :"treatment.substance" => mapping_entry("Genotype", proc do |data|
                if data =~ treatment_substance_regex
                  $2 ? $2 : ""
                else
                  ""
                end
              end),
              :"treatment.concentration" => mapping_entry("Dose/route of adminstration", proc do |data|
                if data =~ treatment_concentration_unit_regex
                  $1 ? $1 : nil
                else
                  nil
                end
              end),
              :"treatment.unit" => mapping_entry("Dose/route of adminstration", proc do |data|
                if data =~ treatment_concentration_unit_regex
                  $2 ? $2 : ""
                else
                  ""
                end
              end),

              :"samples.comments" => mapping_entry("FIXED", proc {""}),
              :"samples.title" => mapping_entry("Sample ID"),
              :"samples.sample_type" => mapping_entry("FIXED", proc {""}),
              :"samples.donation_date" => mapping_entry("Arrival Date"),

              :"tissue_and_cell_types.title" => mapping_entry("FIXED", proc {""}),

              :"sop.title" => mapping_entry("FIXED", proc {""}),
              :"institution.name" => mapping_entry("FIXED", proc {""})
          },


          :assay_mapping => nil


      }

    end

    # mapping for duesseldorf excel sheet
    # example file: due_bode_Tierbestandsliste G96 parsing format.xls
    def duesseldorf_bode_mapping

      concentration_regex = /(\d*,?\.?\d*).*/

      {
              :name => "duesseldorf_bode",
              :data_row_offset => 1,


              :samples_mapping => {
                  :samples_sheet_name => "Tabelle2",
                  :add_specimens => true,
                  :add_treatments => true,
                  :add_samples => false,

                  :probing_column => :"specimens.title",

                  :"organisms.title" => mapping_entry("species"),

                  :"strains.title" => mapping_entry("strain"),

                  :"specimens.sex" => mapping_entry("sex"),
                  :"specimens.title" => mapping_entry("Animal Nr."),
                  :"specimens.lab_internal_number" => mapping_entry("Animal Nr."),
                  :"specimens.age" => mapping_entry("Age (Weeks)"),
                  :"specimens.age_unit" => mapping_entry("FIXED", proc {"week"}),
                  :"specimens.comments" => mapping_entry("Specials", proc {|data| data == "-" ? "" : data }),
                  :"specimens.genotype.title" => mapping_entry("FIXED", proc {"none"}),
                  :"specimens.genotype.modification" => mapping_entry("FIXED", proc{""}),

                  :"treatment.treatment_protocol" => mapping_entry("FIXED", proc {""}),
                  :"treatment.substance" => mapping_entry("FIXED", proc {"LPS"}),
                  :"treatment.concentration" => mapping_entry("LPS (µg/g KG)", proc do |data|
                    if data =~ concentration_regex
                      $1
                    else
                      ""
                    end
                  end),
                  :"treatment.unit" => mapping_entry("FIXED", proc {"µg/g KG"}),

                  #:"samples.comments" => mapping_entry(""),
                  #:"samples.title" => mapping_entry(""),
                  #:"samples.sample_type" => mapping_entry(""),
                  #:"samples.donation_date" => mapping_entry(""),

                  #:"tissue_and_cell_types.title" => mapping_entry(""),

                  #:"sop.title" => mapping_entry(""),
                  #:"institution.name" => mapping_entry("")
              },


              :assay_mapping => {

                  :assay_sheet_name => "",

                  :"investigation.title" => mapping_entry(""),
                  :"assay_type.title" => mapping_entry(""),
                  :"study.title" => mapping_entry(""),

                  :"creator.email" => mapping_entry(""),
                  :"creator.last_name" => mapping_entry(""),
                  :"creator.first_name" => mapping_entry("")

              }

      }

    end

    def unknown_mapping
      nil
    end


    def empty_mapping # defines basic mapping to start with, not that useful for the real parsing business ;-)
      {
          :name => "",
          :data_row_offset => 1, # add this to the row of a header column to get to row with the first data element

          :samples_mapping => {     # TODO: which fields are really necessary?
              :samples_sheet_name => "",  # required

              :add_specimens => true,
              :add_treatments => true,
              :add_samples => true,

              :probing_column => :"specimens.title",  # this should map to a column that has no blank elements in between other elements

              :"organisms.title" => mapping_entry(""),

              :"strains.title" => mapping_entry(""),

              :"specimens.sex" => mapping_entry(""),
              :"specimens.title" => mapping_entry(""),
              :"specimens.lab_internal_number" => mapping_entry(""),
              :"specimens.age" => mapping_entry(""),
              :"specimens.age_unit" => mapping_entry(""),
              :"specimens.comments" => mapping_entry(""),
              :"specimens.genotype.title" => mapping_entry("FIXED", proc {"none"}),
              :"specimens.genotype.modification" => mapping_entry("FIXED", proc {""}),

              :"treatment.treatment_protocol" => mapping_entry(""),
              :"treatment.substance" => mapping_entry(""),
              :"treatment.concentration" => mapping_entry(""),
              :"treatment.unit" => mapping_entry(""),

              :"samples.comments" => mapping_entry(""),
              :"samples.title" => mapping_entry(""),
              :"samples.sample_type" => mapping_entry(""),
              :"samples.donation_date" => mapping_entry(""),

              :"tissue_and_cell_types.title" => mapping_entry(""),

              :"sop.title" => mapping_entry(""),
              :"institution.name" => mapping_entry("")
          },


          :assay_mapping => {      # can be nil if no assays are mapped

              :assay_sheet_name => "",

              :"investigation.title" => mapping_entry(""),
              :"assay_type.title" => mapping_entry(""),
              :"study.title" => mapping_entry(""),

              :"creator.email" => mapping_entry(""),
              :"creator.last_name" => mapping_entry(""),
              :"creator.first_name" => mapping_entry("")

          }


      }

    end



  end

end