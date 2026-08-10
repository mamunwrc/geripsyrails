geripsy.factory 'Reviewer', ['$resource', ($resource) ->
  _resource = $resource '/api/reviewers/:id', 
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

]
