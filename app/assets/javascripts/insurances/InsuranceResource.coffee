geripsy.factory 'Insurance', ['$resource', ($resource) ->
  $resource '/api/insurances/:id', 
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

    index:
      method: 'GET'
      url: '/api/insurances'
      isArray: true
      headers:
        'Content-Type': 'application/json'

]
