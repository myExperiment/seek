module IndexPager    

  def index
    controller = self.controller_name.downcase    
    model_name=controller.classify
    model_class=eval(model_name)
    objects = eval("@"+controller)
    objects.size
    @hidden=0
    params[:page] ||= Seek::Config.default_page(controller)

    objects=model_class.paginate_after_fetch(objects, :page=>params[:page],
                                                      :latest_limit => Seek::Config.limit_latest
                                            ) unless objects.respond_to?("page_totals")
    eval("@"+controller+"= objects")

    respond_to do |format|
      format.html
      format.xml
    end

  end

  def find_assets
    controller = self.controller_name.downcase
    model_class=controller.classify.constantize
    if model_class.respond_to? :all_authorized_for
      found = model_class.all_authorized_for "view",User.current_user
    else
      found = model_class.default_order
    end
    found = apply_filters(found)
    
    eval("@" + controller + " = found")
  end
  
end