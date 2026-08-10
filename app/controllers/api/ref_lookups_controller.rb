class Api::RefLookupsController < Api::BaseController
  respond_to :json

  def index
    group = params[:group]
    group = 'main' if group.blank?
    @lookups = Ref::Lookup.where(group: group )
    respond_with @lookups.group_by(&:keyprefix)
  end
end
