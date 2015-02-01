'use strict';

// Declare app level module which depends on filters, and services
angular.module('raspyApp', ['ngRoute']).
  config(['$routeProvider', function($routeProvider) {
    $routeProvider.
    	when('/index', {templateUrl: 'partials/index.html'}).
    	when('/contact', {templateUrl: 'partials/contact.html'}).
    	when('/domoticz', {templateUrl: 'domoticz/index.html'}).
    	otherwise({redirectTo: '/index'});
  }]);
