'''
@yvan May 5 2018

Resources/Credits:

http://codentronix.com/2011/04/21/rotating-3d-wireframe-cube-with-python/
http://www.petercollingridge.co.uk/pygame-3d-graphics-tutorial/nodes-and-edges
http://www.petercollingridge.co.uk/pygame-physics-simulation
'''

import math

class Node(object):
    '''
    A point in our 3d mesh.
    Args:
        :param coordinates: (tuple) a tuple of 3 float values representing a point
    '''
    def __init__(self, coordinates):
        self.x = coordinates[0]
        self.y = coordinates[1]
        self.z = coordinates[2]

class Edge(object):
    '''
    An edge between two points in our 3d mesh.
    Args:
        :param beg: (int) The index in the nodes list of the beginning node in the edge.
        :param end: (int) The index in the nodes list of the ending node in the edge.
    '''
    def __init__(self, beg, end):
        self.beg = beg
        self.end = end

class Wireframe(object):
    '''
    A wireframe for our 3d model.
    '''
    def __init__(self):
        self.nodes = []
        self.edges = []

    def add_nodes(self, node_list):
        '''
        Add a list of nodes to our wireframe
        Args:
            :param node_list: (list[Node]) A list of Node type objects 
        '''
        for node in node_list:
            self.nodes.append(Node(node))

    def add_edges(self, edge_list):
        '''
        Add a list of edges to our wireframe
        Args:
            :param edge_list: (list(int, int))]) A list of tuples where each tuple element is an index into the nodes of the wireframe.
        '''

        for (beg, end) in edge_list:
            self.edges.append(Edge(self.nodes[beg], self.nodes[end]))

    def output_nodes(self):
        '''
        Print the nodes of the wireframe
        '''
        print('\n--- nodes (x, y, z) --- ')
        for i, node in enumerate(self.nodes):
            print(f'{i} ({node.x}, {node.y}, {node.z})')

    def output_edges(self):
        '''
        Print the edges of the wireframe
        '''
        print('\n--- edges (p1 <-> p2) --- ')
        for i, edge in enumerate(self.edges):
            print(f'{i} ({edge.beg.x}, {edge.beg.y}, {edge.beg.z}) - ({edge.end.x}, {edge.end.y}, {edge.end.z})')

    def translate(self, axis, d):
        '''
        Add a constant value to the axis specified
        Args:
            :param axis: (str) a string, 'x', 'y', or 'z' indicating the axis to translate
            :param d: (float/int) a value telling how much to translate the specified axis
        '''
        if axis in ['x', 'y', 'z']:
            for node in self.nodes:
                setattr(node, axis, getattr(node, axis) + d)
        else:
            print('Make sure your axis is x,y,z and your transaltion value (d) is numeric!')
    
    def scale(self, center_x, center_y, scale):
        '''
        Scale the size of the wireframe from the center position on the screen.
        Args:
            :param center_x: The center of the pygame screen in the x axis.
            :param center_y: The center of the pygame screen in the y axis.
            :param scale: The paramter which determines resizing, scale > 1 (make wireframe bigger), scale < 1 (make wireframe smaller)
        '''
        for node in self.nodes:
            node.x = center_x + scale * (node.x - center_x)
            node.y = center_y + scale * (node.y - center_y)
            node.z *= scale

    def find_center(self):
        '''
        Find the center of our cube.
        '''
        num_nodes = len(self.nodes)
        mean_x = sum([node.x for node in self.nodes]) / num_nodes
        mean_y = sum([node.y for node in self.nodes]) / num_nodes
        mean_z = sum([node.z for node in self.nodes]) / num_nodes
        return (mean_x, mean_y, mean_z)

    def rotate_z(self, center, radians):
        '''
        Rotate teh cube about the z axis.
        Args:
            :params center: (tuple(float,float,float)) cx, cy, cz, is the input which represents the center about which you'd like to rotate
            :param radians: (float) the amount of radians you want to rotate about the z axis by.
        '''
        cx, cy, cz = center
        for node in self.nodes:
            x = node.x - cx
            y = node.y - cy
            d = math.hypot(y, x)
            theta = math.atan2(y, x) + radians
            node.x = cx + d * math.cos(theta)
            node.y = cy + d * math.sin(theta)

    def rotate_x(self, center, radians):
        '''
        Rotate teh cube about the x axis.
        Args:
            :params center: (tuple(float,float,float)) cx, cy, cz, is the input which represents the center about which you'd like to rotate
            :param radians: (float) the amount of radians you want to rotate about the x axis by.
        '''
        cx, cy, cz = center
        for node in self.nodes:
            y = node.y - cy
            z = node.z - cz
            d = math.hypot(y, z)
            theta = math.atan2(y, z) + radians
            node.y = cy + d * math.sin(theta)
            node.z = cz + d * math.cos(theta)

    def rotate_y(self, center, radians):
        '''
        Rotate teh cube about the y axis.
        Args:
            :params center: (tuple(float,float,float)) cx, cy, cz, is the input which represents the center about which you'd like to rotate
            :param radians: (float) the amount of radians you want to rotate about the x axis by.
        '''
        cx, cy, cz = center
        for node in self.nodes:
            x = node.x - cx
            z = node.z - cz
            d = math.hypot(x, z)
            theta = math.atan2(x, z) + radians
            node.x = cx + d * math.sin(theta)
            node.z = cz + d * math.cos(theta)

if __name__ == '__main__':
    cube_nodes = [(x,y,z) for x in (0,1) for y in (0,1) for z in (0,1)]
    cube = Wireframe()
    cube.add_nodes(cube_nodes)
    cube.add_edges([(n,n+4) for n in range(0,4)])
    cube.add_edges([(n,n+1) for n in range(0,8,2)])
    cube.add_edges([(n,n+2) for n in (0,1,4,5)])
    cube.output_nodes()
    cube.output_edges()
