controllers = angular.module('controllers')
controllers.controller("AppointmentsController", ['$http','$filter','$scope', '$routeParams', '$location', '$modal', 'appointmentsFactory'
  ($http,$filter,$scope,$routeParams,$location,$modal,appointmentsFactory)->

    appointmentsFactory.query((results)-> $scope.appointments = results)

    $scope.searchTerm = ""

    $scope.calendarView = true
    
    $scope.openNew = (size) ->
      modalInstance = $modal.open(
        templateUrl: 'appointment_form.html'
        controller: 'AppointmentModalController'
        size: size
        resolve:
          appointmentId: ->
            return null
          patientId: ->
            return null
      )
      modalInstance.result.then ((updatedPatient) ->
        appointmentsFactory.query((results)-> $scope.appointments = results)
        return
      ), ->
        console.log 'Modal dismissed at: ' + new Date
        return
      return

    orderBy = $filter('orderBy');
    $scope.order = (predicate, reverse) ->
      $scope.appointments = orderBy($scope.appointments, predicate, reverse)
      getCalendarEvents()
      return

    $scope.openEdit = (size, appointmentId) ->
      modalInstance = $modal.open(
        animation: $scope.animationsEnabled
        templateUrl: 'appointment_form.html'
        controller: 'AppointmentModalController'
        size: size
        resolve:
          appointmentId: ->
            return appointmentId
          patientId: ->
            return null
      )
      modalInstance.result.then ((updatedPatient) ->
        appointmentsFactory.query((results)-> $scope.appointments = results)
        getCalendarEvents()
        return
      ), ->
        console.log 'Modal dismissed at: ' + new Date
        return
      return


    date = new Date()
    d = date.getDate()
    m = date.getMonth()
    y = date.getFullYear()

    getCalendarEvents = ->
      $http.get('/appointments_calendar?format=json').success((data, status, headers, config) ->
            $scope.appointmentsCalendar = data
            initCalendar()
            return
          ).error (data, status, headers, config) ->
            flash.error   = "There was a problem with your request."
            return

    initCalendar = ->
      $scope.calendarInstance = $('#calendar').fullCalendar(
        editable: false
        droppable: false  
        header:
          left: 'prev,next'
          center: 'title'
          right: 'month,agendaWeek,agendaDay'
        events: $scope.appointmentsCalendar
      )

    getCalendarEvents()
])