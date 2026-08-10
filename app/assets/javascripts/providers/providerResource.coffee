geripsy.factory 'Provider', ['$resource', ($resource) ->
  _resource = $resource '/api/providers/:id', 
    {id: '@id'}
    query:
      method: 'GET'
      isArray: true
    get:
      method: 'GET'
      isArray: false
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

    incident_to_providers:
      url: '/api/providers/incident_to_providers'
      method: 'GET'
      isArray: true

    add_patient:
      url: '/api/providers/:provider_id/patients'
      method: 'POST'

    rm_patient:
      url: '/api/providers/:provider_id/patients/:id'
      method: 'DELETE'

    testings_list:
      url: 'api/providers/:provider_id/testings'
      method: 'GET'
      isArray: true

  _.tap _resource, (res) ->
    res.prototype.fullName = ->
      return "" unless @user
      @user.first_name + ' ' + @user.last_name
    res.prototype.email = ->
      return "" unless @user
      @user.email

]
