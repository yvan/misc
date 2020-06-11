
//JSC3D.console.setup('product-viwerdiv', '100px');
//JSC3D.console.setup('product-viwerdiv', '100px');

dash = '-';

var viewer_array = [number_models];

var model_counter = 0;

for(var i = 0; i < number_models; i++){

    model_counter = i;

	if (i==0){

		i='';
	}

    var canvas = document.getElementById('canvas' + i);
    var viewer = new JSC3D.Viewer(canvas);

    //this code should never trigger. I added it in as a redundant feature just in case there are bugs
    //malicious users tampering with teh JS.
    if (i == 0){

    	viewer.setParameter('SceneUrl', 'http://localhost:8888/cakephp-cakephp-0a6d85c/app/webroot/img/models/' + id + '.' + model_ext[model_counter]); /*'.stl'*/
    }
    else{
        
    	viewer.setParameter('SceneUrl', 'http://localhost:8888/cakephp-cakephp-0a6d85c/app/webroot/img/models/' + id + dash + i + '.' + model_ext[model_counter]); //'.stl'
    }
    
    viewer.setParameter('InitRotationX', 0);
    viewer.setParameter('InitRotationY', 0);
    viewer.setParameter('InitRotationZ', 0);
    viewer.setParameter('ModelColor', '#00C78C');
    viewer.setParameter('BackgroundColor1', '#FCFCFC');
    viewer.setParameter('BackgroundColor2', '#FCFCFC');
    viewer.setParameter('RenderMode', 'flat');
    viewer.setParameter('Definition', 'high');
    viewer.init();
    viewer.update();

    if (!viewer.isLoaded()){

    if (i == 0){

        viewer.setParameter('SceneUrl', 'http://localhost:8888/cakephp-cakephp-0a6d85c/app/webroot/img/models/' + id +'.' + model_ext[model_counter]);
    }

    else{

        viewer.setParameter('SceneUrl', 'http://localhost:8888/cakephp-cakephp-0a6d85c/app/webroot/img/models/' + id + dash + i + '.' + model_ext[model_counter]);
    }
    viewer.update();
    }
    

    if (i==''){

    	i=0;
    }

    viewer_array[i] = viewer;
}

function changeBodyColor2(color) {

    for (var i=0; i < number_models; i++){

        var mesh;

        mesh = viewer_array[i].getScene().getChildren()[0];
        mesh.setMaterial(new JSC3D.Material('', 0, color, 0, true));
        viewer_array[i].update();
    }

    for (var i=0; i < number_models; i++){

        var mesh;

        mesh = viewer_array_complete[i].getScene().getChildren()[0];
        mesh.setMaterial(new JSC3D.Material('', 0, color, 0, true)); 
        viewer_array_complete[i].update();
    }
}

function resetPerspective(){

    for (var i=0; i < number_models; i++){

        viewer_array[i].resetScene();
        viewer_array[i].update();
    }

    for (var i=0; i < number_models; i++){

        viewer_array_complete[i].resetScene();
        viewer_array_complete[i].update();
    }
}

//sets the zoom level on the viewer
function zoomIn(){

    for (var i=0; i < number_models; i++){
        
        viewer_array[i].zoomFactor = Math.min(200,viewer_array[i].zoomFactor+5);
        viewer_array[i].update();
    }

    for (var i=0; i < number_models; i++){
        
        viewer_array_complete[i].zoomFactor = Math.min(200,viewer_array_complete[i].zoomFactor + 5);
        viewer_array_complete[i].update();
    }
}
//max prevents us from going below 0, zoomFactor
function zoomOut(){

    for (var i=0; i < number_models; i++){

        viewer_array[i].zoomFactor = Math.max(1, viewer_array[i].zoomFactor - 5);
        viewer_array[i].update();
    }

    for (var i=0; i < number_models; i++){

        viewer_array_complete[i].zoomFactor = Math.max(1, viewer_array_complete[i].zoomFactor-5);
        viewer_array_complete[i].update();
    }
}     
//from http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
//creates a unique id for comments
function createUUID() {
    // http://www.ietf.org/rfc/rfc4122.txt
    var s = [];
    var hexDigits = "0123456789abcdef";
    for (var i = 0; i < 36; i++) {
        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
    }
    s[14] = "4";  // bits 12-15 of the time_hi_and_version field to 0010
    s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
    s[8] = s[13] = s[18] = s[23] = "-";

    var uuid = s.join("");
    return uuid;
}