// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require angular/angular
//= require raven-js/dist/raven.js
//= require raven-js/dist/plugins/angular.js
//= require angular-ui-router
//= require angular-animate
//= require angular-aria
//= require angular-material
//= require angular-messages
//= require moment
//= require moment-timezone
//= require angular-moment
//= require angular-sanitize
//= require angular-resource
//= require angular-cookies
//= require angular-devise
//= require lodash/lodash
//= require lodash-inflection
//= require angular-rails-templates
//= require angular-scroll
//= require viPickers/dist/mdPickers.min.js
//= require angular-paginate-anything/dist/paginate-anything-tpls
//= require angular-loading-bar
//= require app
//= require_tree .

function momentu2(date) {
  var offset = - new Date().getTimezoneOffset();

  if(typeof (date || {}).getTimezoneOffset === 'function') {
    offset = -date.getTimezoneOffset();
  } else if(date) {
    var match = date.toString().match(/GMT([\+-]\d+)/);
    if(match) offset = match[1];
  }

  return moment(date).utcOffset(offset)
}

function momentu(date, opts) {
  function offset(d) {
    var x = moment(d);
    var offsetmins = x.utcOffset();
    var timefunc = offsetmins > 0 ? 'add' : 'subtract'
    return x[timefunc](offsetmins, 'minutes')
  }

  if((opts || {}).forceMidnight) {
    var datestring = moment(date).format("L");
    return momentu(new Date(datestring))
  } else if(moment(date).utc().hour() === 0) {
    return offset(date);
  } else if(moment(date).utcOffset() !== 0 && moment(date).hour() === 0) {
    return offset(offset(date));
  } else {
    return moment(date);
  }
}
