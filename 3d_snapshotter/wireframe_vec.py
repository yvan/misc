'''
@yvan May 5 2018

vectorized implementation fo the 3d cube viewer.
'''

import numpy as np

def create_translation_matrix(dx=0, dy=0, dz=0):
    '''
    Return a matrix for the translation along vector (dx, dy ,dz)
    Args:
        :param dx: (numeric) value to trsanlate in the x axis
        :param dy: (numeric) value to trsanlate in the y axis
        :param dz: (numeric) value to trsanlate in the z axis
    '''
    return np.array([
                    [1,0,0,0],
                    [0,1,0,0],
                    [0,0,1,0],
                    [dx,dy,dz,1]
                    ])

def create_scale_matrix(s, cx=0, cy=0, cz=0):
    '''
    Return a matrix to scale along axes centered on cx, cy, cz
    Args:
        :param s: (numeric) the scaling factor for resizing the wireframes
        :param cx: (numeric) center x value
        :param cy: (numeric) center y value
        :param cz: (numeric) center z value
    '''
    return np.array([
                    [s,0,0,0],
                    [0,s,0,0],
                    [0,0,s,0],
                    [cx*(1-s),cy*(1-s),cz*(1-s),1]
                    ])

def create_rot_x(radians):
    '''
    Create a rotation matrix for rotating however many radians around x.
    Args:
        :param radians: (numeric) the amount of radians to rotate by
    '''
    c = np.cos(radians)
    s = np.sin(radians)
    return np.array([
                    [1,0,0,0],
                    [0,c,-s,0],
                    [0,s,c,0],
                    [0,0,0,1]
                    ])

def create_rot_y(radians):
    '''
    Create a rotation matrix for rotating around y by radians.
    Args:
        :param radians: (numeric) the amount of radians to rotate by
    '''
    c = np.cos(radians)
    s = np.sin(radians)
    return np.array([
                    [c,0,s,0],
                    [0,1,0,0],
                    [-s,0,c,0],
                    [0,0,0,1]
                    ])

def create_rot_z(radians):
    '''
    Create a rotation matrix for rotating around z by radians.
    Args:
        :param radians: (numeric) the amount of radians to rotate by
    '''
    c = np.cos(radians)
    s = np.sin(radians)
    return np.array([
                    [c,-s,0,0],
                    [s,c,0,0],
                    [0,0,1,0],
                    [0,0,0,1]
                    ])

class Wireframe(object):
    '''
    A wireframe for our 3d model.
    '''
    def __init__(self):
        self.nodes = np.zeros((0,4))
        self.edges = []
        self.faces = []

    def add_nodes(self, node_array):
        '''
        Add a list of nodes to our wireframe
        Args:
            :param node_array: (np.array) An N x 3 numpy array, where the elements are x,y,z positions 
        '''
        ones_col = np.ones((len(node_array), 1))
        ones_add = np.hstack((node_array, ones_col))
        self.nodes = np.vstack((self.nodes, ones_add))

    def set_nodes(self, node_array):
        '''
        Set a list of nodes to our wireframe, useful for resetting nodes
        Args:
            :param node_array: (np.array) An N x 3 numpy array, where the elements are x,y,z positions 
        '''
        self .nodes = np.zeros((0,4))
        ones_col = np.ones((len(node_array), 1))
        ones_add = np.hstack((node_array, ones_col))
        self.nodes = np.vstack((self.nodes, ones_add))

    def add_edges(self, edge_list):
        '''
        Add a list of edges to our wireframe
        Args:
            :param edge_list: (list(list(int, int)) A list of tuples where each tuple element is an index into the nodes array of the wireframe.
        '''

        self.edges += edge_list

    def add_faces(self, face_list, face_colors):
        for node_list, color in zip(face_list, face_colors):
            num_nodes = len(node_list)
            if all(node < len(self.nodes) for node in node_list):
                self.faces.append((node_list, np.array(color, np.uint8)))
                self.add_edges([(node_list[n-1], node_list[n]) for n in range(num_nodes)])

    def output_nodes(self):
        '''
        Print the nodes of the wireframe. x,y,z are position parameters,
        e is an extra parameter to make matrix multiplication easier.
        '''
        print('\n--- nodes (x, y, z, _) --- ')
        for i, (x,y,z,e) in enumerate(self.nodes):
            print(f'{i} ({x}, {y}, {z}, {e})')

    def output_edges(self):
        '''
        Print the edges of the wireframe
        '''
        print('\n--- edges (p1 <-> p2) --- ')
        for i, (node1, node2) in enumerate(self.edges):
            print(f'{i} {node1} - {node2}')

    def output_faces(self):
        '''
        Print faces of the wireframe
        '''
        print('\n--- faces --- ')
        for i, nodes in enumerate(self.faces):
            f = ', '.join([f'{n}' for n in nodes])
            print(f'{i}: {f}')

    def transform(self, matrix):
        '''
        Apply an arbitrary transformation matrix via bultin python dot product operator.
        '''
        self.nodes = self.nodes @ matrix

    def find_center(self):
        '''
        Find the center of our cube.
        '''
        # go column by column find the smallest x,y,z
        min_values = self.nodes[:,:-1].min(axis=0)
        # got through each column adn find the biggest x,y,z
        max_values = self.nodes[:,:-1].max(axis=0)
        # add them together and divide by 2
        return 0.5*(min_values + max_values)

    def center_wireframe(self, screen_center):
        '''
        Performs a translation on the wireframe such that its
        find_center would return the middle of the screen.
        Args:
            :param screen_center: (tuple) that give the x,y,z coordinated of the center.
        '''
        # find the center of the cube
        c = self.find_center()
        # find the difference between the center
        # and the screen center
        diff = screen_center - c
        mt = create_translation_matrix(*diff)
        self.transform(mt)

    def sorted_faces(self):
        return sorted(self.faces, key=lambda face: min(self.nodes[f][2] for f in face[0]))

if __name__ == '__main__':
    cube_nodes = [(x,y,z) for x in (0,1) for y in (0,1) for z in (0,1)]
    cube = Wireframe()
    cube.add_nodes(np.array(cube_nodes))
    cube.add_edges([(n,n+4) for n in range(0,4)])
    cube.add_edges([(n,n+1) for n in range(0,8,2)])
    cube.add_edges([(n,n+2) for n in (0,1,4,5)])
    cube.add_faces([(0,1,3,2), (7,5,4,6), (4,5,1,0), (2,3,7,6), (0,2,6,4), (5,7,3,1)],
                   [(255, 255, 255), (154,205,50), (128,0,0), (70,130,180), (75,0,130), (199,21,133)])
    cube.output_nodes()
    cube.output_edges()
    cube.output_faces()

'''
Resources/Credits:

http://codentronix.com/2011/04/21/rotating-3d-wireframe-cube-with-python/
http://www.petercollingridge.co.uk/pygame-3d-graphics-tutorial/nodes-and-edges
http://www.petercollingridge.co.uk/pygame-physics-simulation
'''
