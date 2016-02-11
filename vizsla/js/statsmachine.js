/*
Kelvin Betances
Stats Machine on county dataset in JSON
Displays the average, minimum, and maximum values in our county dataset for a
different range of categories.
*/
var countyData = require('../json/countydata.json');
countyData = JSON.parse(JSON.stringify(countyData));

var statCategories = ["Poverty Estimate, All Ages",
"Poverty Estimate, Under Age 18", "Poverty Estimate, Ages 5-17 in Families", "Median Household Income"];
var options = ["Averages:", "Minimums:", "Maximums: "];

function displayInformation()
{
      console.log("### Dataset Summary ###");

      console.log("--------------------------------------");
      console.log(">Poverty Estimate, All Ages:");
      console.log("Average Value:" + findAverage(7) + "%");
      console.log("Minimum Value:" + findMin(7) + "%" );
      console.log("Maximum Value:" + findMax(7) + "%");

      console.log("--------------------------------------");
      console.log(">Poverty Estimate, Under Age 18:");
      console.log("Average Value:" + findAverage(10) + "%" );
      console.log("Minimum Value:" + findMin(10) + "%" );
      console.log("Maximum Value:" + findMax(10) + "%");

      console.log("--------------------------------------");
      console.log(">Poverty Estimate, Ages 5-17 in Families:");
      console.log("Average Value:" + findAverage(17) + "%" );
      console.log("Minimum Value:" + findMin(17) + "%" );
      console.log("Maximum Value:" + findMax(17) + "%" );

      console.log("--------------------------------------");
      console.log(">Median Household Income:");
      console.log("Average Value:" + "$" + findAverage(23) );
      console.log("Minimum Value:" + "$" + findMin(23) );
      console.log("Maximum Value:" + "$" + findMax(23) );

}

//find the average in our dataset.
function findAverage(category)
{
  var avg = 0;
  var counter = 0;

  for (var key in countyData)
  {
    var value = countyData[key];
    if(value[category] != ".")
    {
      avg += parseInt(value[category]);
      counter += 1;
    }
  }
  avg /= counter;
  return avg;
}

//find the minimum value in our dataset.
function findMin(category)
{
  var min = [];

  for (var key in countyData)
  {
    var value = countyData[key];
    if(value[category] != ".")
      min.push(parseInt(value[category]));
  }

  min.sort();
  return min[0];

}
function findMax(category)
{
  var max = [];
  for (var key in countyData)
  {
    
    var value = countyData[key];
    if(value[category] != ".")
      max.push(value[category]);

  }

  max.sort();

  return max[max.length-1];

}

displayInformation();
