geripsy.factory 'Practice', ['$resource', ($resource) ->
  $resource '/api/practices/:id', 
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

    add_provider:
      url: '/api/practices/:practice_id/providers'
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
    rm_provider:
      url: '/api/practices/:practice_id/providers/:id'
      method: 'DELETE'
      isArray: true
      headers:
        'Content-Type': 'application/json'

    add_facility:
      url: '/api/practices/:practice_id/facilities'
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
    rm_facility:
      url: '/api/practices/:practice_id/facilities/:id'
      method: 'DELETE'
      isArray: true
      headers:
        'Content-Type': 'application/json'
]
