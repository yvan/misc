/* We need
1. A scene
2. A renderer
3. A camera
4. An object
*/

var WIDTH = 1000, HEIGHT = 1000

var scene = new THREE.Scene()

var renderer = new THREE.WebGLRenderer()
renderer.setSize(WIDTH, HEIGHT)

var VIEW_ANGLE = 45,
	ASPECT = WIDTH / HEIGHT
	NEAR = 0.1
	FAR = 10000

var camera = new THREE.PerspectiveCamera(
	VIEW_ANGLE,
	ASPECT,
	NEAR,
	FAR
	)
scene.add(camera)

camera.position.z = 300

var $container = $('#container')
$container.append(renderer.domElement)

var radius = 50,
	segments = 16,
	rings = 16

var sphereMaterial = new THREE.MeshLambertMaterial({
	color: 0xCC0000
})

var sphere = new THREE.Mesh(

	new THREE.SphereGeometry(
		radius,
		segments,
		rings
	),
	sphereMaterial
)
scene.add(sphere)

var pointLight = new THREE.PointLight(0xFFFFFF)

pointLight.position.x = 10
pointLight.position.y = 50
pointLight.position.z = 130

scene.add(pointLight)

renderer.render(scene, camera)
