geripsy.factory 'User', ['$http', ($http) ->
  update: (user) ->
    $http.patch "/api/users/#{user.id}", {user: user}
]
