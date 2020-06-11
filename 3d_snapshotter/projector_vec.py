'''
@yvan may 5 2018

vectorized implementation of the simple 3d cube viewer.

'''
import sys
import pygame
import datetime
import numpy as np
import wireframe_vec as wf

key_to_movement = {
    pygame.K_LEFT: lambda x: x.translate_all([-10, 0, 0]),
    pygame.K_RIGHT: lambda x: x.translate_all([10, 0, 0]),
    pygame.K_DOWN: lambda x: x.translate_all([0, 10, 0]),
    pygame.K_UP: lambda x: x.translate_all([0, -10, 0]),
    pygame.K_EQUALS: lambda x: x.scale_all(1.25),
    pygame.K_MINUS: lambda x: x.scale_all(0.8),
    pygame.K_q: (lambda x: x.rotate_all('x',  0.1)),
    pygame.K_w: (lambda x: x.rotate_all('x', -0.1)),
    pygame.K_a: (lambda x: x.rotate_all('y',  0.1)),
    pygame.K_s: (lambda x: x.rotate_all('y', -0.1)),
    pygame.K_z: (lambda x: x.rotate_all('z',  0.1)),
    pygame.K_x: (lambda x: x.rotate_all('z', -0.1))
}

class Projector(object):
    '''
    Makes 2D projections of 3d wireframes on a pygame screen.
    '''
    def __init__(self, width, height):
        self.width = width
        self.height = height
        pygame.init()
        self.screen = pygame.display.set_mode((width, height))
        pygame.display.set_caption('Wireframe Display')
        self.background = (10,10,50)

        self.wireframes = {}
        self.display_nodes = False
        self.display_edges = False
        self.display_faces = True
        self.manual_mode = False # mode for manually taking pictures
        self.node_color = (255, 255, 255)
        self.edge_color = (255, 255, 255)
        self.node_radius = 4 # how big the 'points' are in our cube
        self.light = wf.Wireframe()
        self.light.add_nodes([[0, -1, 0]])
        self.min_light = 0.02
        self.max_light = 1.0
        self.light_range = self.max_light - self.min_light
        self.perspective = 300
        self.fps = 5
        self.limit_samples = False #10000

    def add_wireframe(self, name, wireframe):
        '''
        Add a wireframe to our scene.
        ''' 
        self.wireframes[name] = wireframe

    def run(self):
        '''
        Run pygame and dispaly our wireframes
        '''
        # clock to slow thigns down a bit to 
        # get better images
        clockobject = pygame.time.Clock()
        running = True
        seq_step = 0
        seq = self.create_rotation_sequence()
        # store a numpy array for every wireframe
        # some may differ. this will allow us to 
        # create entire scenes and learn them later
        # if we want to do that
        if self.limit_samples: 
            row_count = self.limit_samples
        else:
            row_count = len(seq)
        rotation_positions = []
        for _, wireframe in self.wireframes.items():
            # for every wireframe, there needs to be rows for every frame #len(seq)
            # within each of those we need a dimension for the number of nodes in the
            # wireframe, and then 3 slots for x,y,z coords for that node, first 3 are 
            # position next 3 are rotation in x,y,z 
            rotation_positions.append(np.zeros((row_count,wireframe.nodes.shape[0],6)))

        while running:
            clockobject.tick(self.fps)
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYDOWN:
                    if event.key in key_to_movement.keys():
                        key_to_movement[event.key](self)

            for radians, axis in zip(seq[seq_step] , ('x','y','z')*len(seq)):
                self.rotate_all(axis, radians)
            self.save_projection('cube', str(seq_step))
            # re-center
            cube.center_wireframe((self.width//2, self.width//2,0))

            if not seq_step % 100: print(seq_step / len(seq))

            for _, wireframe in self.wireframes.items():
                array = rotation_positions[0]
                # get teh shapes of the rotations and the wireframe node positions consistent
                # so they can both be inserted into the same np array
                rotation_array = np.tile(np.array(seq[seq_step]), (wireframe.nodes.shape[0],1) )
                array[seq_step] = np.hstack((wireframe.nodes[:, :3], rotation_array))

            seq_step += 1
            if seq_step == len(seq) or seq_step == self.limit_samples:
                break

            self.display()
            pygame.display.update()
            # # re-set positions
            cube.set_nodes(np.array([[x,y,z] for x in (50,250) for y in (50,250) for z in (50,250)]))
            cube.center_wireframe((self.width//2, self.width//2,0))

        self.save_wireframes_positions(rotation_positions, self.wireframes.keys())
        pygame.quit()
        sys.exit()

    def display(self):
        '''
        Draw the wireframes on the pygame screen
        '''
        self.screen.fill(self.background)
        for wireframe in self.wireframes.values():
            nodes = wireframe.nodes
            if self.display_faces:
                for face, color in wireframe.sorted_faces():
                    vector1 = (nodes[face[1]] - nodes[face[0]])[:3]
                    vector2 = (nodes[face[2]] - nodes[face[0]])[:3]

                    # see this https://www.mathsisfun.com/algebra/vectors-cross-product.html
                    normal = np.cross(vector1, vector2)
                    # now multiply it by the negative z axis to
                    # see that the normal points upward in some way
                    # we only want to display those
                    towards_us = np.dot(normal, np.array([0,0,-1]))

                    if towards_us:
                        # convert the x,y,z in our normal
                        # vector to be between 0-1
                        normal /= np.linalg.norm(normal)
                        theta = np.dot(normal, self.light.nodes[0][:3])

                        # if our normal is in the opposite direction of
                        # the light the dot product is negative.
                        # put it in the shade
                        shade = color
                        # if theta < 0:
                        #     shade = self.min_light * color
                        # else:
                        #     shade = (theta * self.light_range + self.min_light) * color
                        pygame.draw.polygon(self.screen, 
                                            shade,
                                            [(nodes[node][0], nodes[node][1]) for node in face],
                                            0)

                        if self.display_edges:
                            for n1, n2 in wireframe.edges:
                                if n1 in face or n2 in face:
                                    pygame.draw.aaline(self.screen,
                                                    self.edge_color,
                                                    wireframe.nodes[n1][:2],
                                                    wireframe.nodes[n2][:2],
                                                    1
                                                )

            if self.display_nodes:
                for node in wireframe.nodes:
                    pygame.draw.circle(self.screen,
                                    self.node_color,
                                    (int(node[0]), int(node[1])),
                                    self.node_radius,
                                    0
                                    )
    def translate_all(self, vector):
        '''
        Translate all wireframes on the screen.
        Args:
            :param vector: (list) a vector that tells us how to translate the wireframe
        '''
        matrix = wf.create_translation_matrix(*vector)
        for _, wireframe in self.wireframes.items():
            wireframe.transform(matrix)

    def scale_all(self, scale):
        '''
        Scale all the wireframes on the the screen.
        Args:
            :param scale: (float) The parameter (scale>1-bigger, scale<1-smaller) telling pygame to scale the wireframes up or down.
        '''
        matrix = wf.create_scale_matrix(scale, self.width/2, self.height/2, 0)
        for _, wireframe in self.wireframes.items():
            wireframe.transform(matrix)

    def rotate_all(self, axis, radians):
        '''
        Rotate all wireframes in the screen.
        Args:
            :axis: The axis on which to rotate x, y, z
            :param radians: The amount in radians to rotate by
        '''
        rotate_func_name = 'create_rot_' + axis
        rotation_matrix = getattr(wf, rotate_func_name)(radians)
        for _,wireframe in self.wireframes.items():
            wireframe.transform(rotation_matrix)


    def save_projection(self, name, idx=datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')):
        '''
        Saves the pygame screen as an image.
        Args:
            :param name: name to give to your image.
            :param idx: an index value to pass in for naming your files, so this is an external counter you pass in
            if you don't pass one in the datetime for right now is used.
        '''
        pygame.image.save(self.screen,f'imgs/{name}_index_{idx}.bmp')

    def rotate_randomly(self):
        '''
        Rotates randomly.
        '''
        rand_n = np.random.random()
        if rand_n < 0.3 :
            self.rotate_all('x',  0.05)
        elif rand_n > 0.3 and rand_n < 0.6:
            self.rotate_all('y',  0.05)
        else:
            self.rotate_all('z', 0.05)

    def create_rotation_sequence(self):
        '''
        Autorotates through all possible combinations of x,y,z
        and takes a screenshot.
        '''
        rotations = []
        for i in np.arange(0, 6.3, 0.3):
            for j in np.arange(0, 6.3, 0.3):
                for k in np.arange(0, 6.3, 0.3):
                    rotations.append((i,j,k))
        return rotations

    def save_wireframes_positions(self, rotation_positions, names):
        for wireframe_points, name in zip(rotation_positions, names):
            # save the file and the numpy version used write
            np.save(f'data/{name}-{np.__version__}.npy', wireframe_points)

if __name__ == '__main__':
    p = Projector(500, 500)
    cube = wf.Wireframe()
    cube.add_nodes(np.array([[x,y,z] for x in (50,250) for y in (50,250) for z in (50,250)]))
    cube.add_edges([(n,n+4) for n in range(0,4)]+[(n,n+1) for n in range(0,8,2)]+[(n,n+2) for n in (0,1,4,5)])
    cube.add_faces([(0,1,3,2), (7,5,4,6), (4,5,1,0), (2,3,7,6), (0,2,6,4), (5,7,3,1)],
                   [(255, 255, 255), (154,205,50), (128,0,0), (70,130,180), (75,0,130), (199,21,133)])
    p.add_wireframe('cube', cube)
    p.run()

'''
Resources / Credits:

http://www.petercollingridge.co.uk/pygame-3d-graphics-tutorial/projecting-3d-objects
'''