module.exports = {

  sample: randomSample,
  toppage: getTopPosts,
  page: loadPage
}
//uses a fisher-yates shuffle
//to produce a random subset of
//the array excluding top page
function randomSample(arrayofposts, size){

}

//gets posts from front page of hackernews
function getTopPosts(arrayofposts){

  temp_struct = []
  url_struct = []
  var i = 0, z = 0
  while(arrayofposts[i]){
    if(arrayofposts[i]['page'] == '1'){
      temp_struct[z] = arrayofposts[i]['title']
      url_struct[z] = arrayofposts[i]['url']
      z++
    }
    i++
  }
  return [temp_struct, url_struct]
}

//loads a page given by the number pageindex
function loadPage(arrayofposts, pageindex){

  temp_struct = []
  url_struct = []
  var i = 0, z = 0
  while(arrayofposts[i]){
    if(arrayofposts[i]['page'] == pageindex){
      temp_struct[z] = arrayofposts[i]['title']
      url_struct[z] = arrayofposts[i]['url']
      z++
    }
    i++
  }
  return  temp_struct ? [temp_struct, url_struct]:"That page doesn't exist!"
}
