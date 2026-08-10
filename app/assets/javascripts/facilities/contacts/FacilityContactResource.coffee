geripsy.factory 'facilityContactService', ['$resource', ($resource) ->
  FacilityContact = $resource '/api/facilities/:facility_id/contacts/:id',
    {facility_id: '@facility_id', id: '@id'}
    update:
      method: 'PATCH'

  facilityContactFactory = (opts) ->
    defaults =
      export_format: 'pdf'
      export_type: 'partial'

    opts = angular.extend(defaults, opts or {})
    new FacilityContact(opts)

  return {
    FacilityContact: FacilityContact
    create: facilityContactFactory
  }
]
