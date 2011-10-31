module Admin::OwnerApplicationsHelper
  def target_path(target)
    "/#{target.class.to_s.pluralize.underscore}/#{target.id}"
  end
end
