'use strict';
define(["app","highcharts","ngload!highcharts-ng"],->
      ['$scope', '$filter','SiteConfig'
        ($scope, $filte,SiteConfig) ->
            $scope.addPoints = ()->
              seriesArray = $scope.chart.series
              rndIdx = Math.floor(Math.random() * seriesArray.length);
              seriesArray[rndIdx].data = seriesArray[rndIdx].data.concat([1, 10, 20])

            $scope.addSeries = ()->
              rnd = []
              for num in [0..10]
                rnd.push(Math.floor(Math.random() * 20) + 1)

              $scope.chart.series.push({
                data: rnd
              })
            $scope.removeRandomSeries = ()->
              seriesArray = $scope.chart.series
              rndIdx = Math.floor(Math.random() * seriesArray.length);
              seriesArray.splice(rndIdx, 1)


            $scope.options = {
              type: 'line'
            }
            $scope.swapChartType = ()->
              if this.chart.options.chart.type is 'line'
                this.chart.options.chart.type = 'bar'
              else
                this.chart.options.chart.type = 'line'

            $scope.chart = {
              options: {
                chart: {
                  type: 'line'
                }
              },
              series: [{
                data: [10, 15, 12, 8, 7]
              }],
              title: {
                text: 'Hello'
              }
            }
      ]
)
