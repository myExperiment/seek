require 'grouped_pagination'
require 'acts_as_cached_tree'

class Strain < ActiveRecord::Base

  include Seek::Rdf::RdfGeneration
  include ActsAsCachedTree
  include Subscribable
  include Seek::Biosamples::PhenoTypesAndGenoTypes

  acts_as_authorized
  acts_as_uniquely_identifiable
  acts_as_favouritable
  acts_as_annotatable :name_field=>:title
  include Seek::Taggable
  grouped_pagination

  belongs_to :organism
  has_many :specimens
  has_many :assay_organisms
  has_many :assays,:through=>:assay_organisms

  before_destroy :destroy_genotypes_phenotypes
  scope :by_title

  scope :without_default,where(:is_dummy=>false)

  delegate :ncbi_uri, :to=>:organism

  validates_presence_of :title, :organism
  validates_presence_of :projects, :unless => Proc.new{|s| s.is_dummy? || Seek::Config.is_virtualliver}

  scope :default_order, order("title")

  searchable(:ignore_attribute_changes_of=>[:updated_at]) do
      text :searchable_terms
  end if Seek::Config.solr_enabled

  def searchable_terms
      text=[title,synonym,comment,provider_name,provider_id,searchable_tags]
      text |= genotypes.compact.collect do |g|
        g.gene.try(:title)
      end
      text |= phenotypes.compact.collect do |p|
        p.description
      end
      text.compact
  end

  def is_default?
    title=="default" && is_dummy==true
  end

  def is_default?
    title=="default" && is_dummy==true
  end

  def self.default_strain_for_organism organism
    organism = Organism.find(organism) unless organism.is_a?(Organism)
    strain = Strain.where(:organism_id=>organism.id,:is_dummy=>true).first
    if strain.nil?
      gene = Gene.find_by_title('wild-type') || Gene.create(:title => 'wild-type')
      genotype = Genotype.new(:gene => gene)
      phenotype = Phenotype.new(:description => 'wild-type')
      strain = Strain.create :organism=>organism,:is_dummy=>true,:title=>"default",:genotypes=>[genotype],:phenotypes=>[phenotype]
    end
    strain
  end

  #gives the long title that includes genotype and phenotype details
  def info
    title + " (" + genotype_info + ' / ' + phenotype_info + ')'
  end



  def parent_strain
    parent_strain = Strain.find_by_id(parent_id)
    parent_strain.nil? ? '' : (parent_strain.title + "(Seek ID=#{parent_strain.id})")
  end

  def state_allows_delete? *args
    (specimens.empty? || ((specimens.count == 1) && specimens.first.is_dummy? && specimens.first.samples.empty?)) && super
  end



  #defines that this is a user_creatable object, and appears in the "New Object" gadget
  def self.user_creatable?
    Seek::Config.organisms_enabled
  end
end
