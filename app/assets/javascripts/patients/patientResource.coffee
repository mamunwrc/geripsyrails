geripsy.factory 'Patient', ['$resource', ($resource) ->
  Item = $resource '/api/patients/:id', 
    {id: '@id'}
    query:
      method: 'GET'
      isArray: true
    update:
      method: 'PATCH'
      headers: 
        'Content-Type': 'application/json'

    addNote:
      method: 'POST'
      url: '/api/patients/:id/notes'
      headers:
        'Content-Type': 'application/json'

    search:
      method: 'GET'
      url: '/api/patients/filter'
      transformResponse: (data, headers) ->
        res =
          data: angular.fromJson(data)
          export_url: headers('x-export-url')

        res

    match:
      method: 'GET'
      url: '/api/patients/match'
      isArray: true

  Item.prototype.fullName = ->
    @first_name + ' ' + @last_name

  Item.prototype.dateOfBirth = ->
    new Date(@dob)

  Item
]
