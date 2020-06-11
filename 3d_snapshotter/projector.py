'''
@yvan may 5 2018

http://www.petercollingridge.co.uk/pygame-3d-graphics-tutorial/projecting-3d-objects
'''
import sys
import pygame
import wireframe

key_to_movement = {
    pygame.K_LEFT: lambda x: x.translate_all('x', -10),
    pygame.K_RIGHT: lambda x: x.translate_all('x', 10),
    pygame.K_DOWN: lambda x: x.translate_all('y', 10),
    pygame.K_UP: lambda x: x.translate_all('y', -10),
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
        self.display_nodes = True
        self.display_edges = True
        self.node_color = (255, 255, 255)
        self.edge_color = (200, 200, 200)
        self.node_radius = 4 # how big the 'points' are in our cube

    def add_wireframe(self, name, wireframe):
        '''
        Add a wireframe to our scene.
        ''' 
        self.wireframes[name] = wireframe

    def run(self):
        '''
        Run pygame and dispaly our wireframes
        '''
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYDOWN:
                    if event.key in key_to_movement.keys():
                        key_to_movement[event.key](self)

            self.display()
            pygame.display.update()
        pygame.quit()
        sys.exit()

    def display(self):
        '''
        Draw the wireframes on the pygame screen
        '''
        self.screen.fill(self.background)

        for wireframe in self.wireframes.values():
            if self.display_edges:
                for edge in wireframe.edges:
                    pygame.draw.aaline(self.screen,
                                    self.edge_color,
                                    (edge.beg.x, edge.beg.y),
                                    (edge.end.x, edge.end.y),
                                    1
                                    )
            if self.display_nodes:
                for node in wireframe.nodes:
                    pygame.draw.circle(self.screen,
                                    self.node_color,
                                    (int(node.x), int(node.y)),
                                    self.node_radius,
                                    0
                                    )
    def translate_all(self, axis, d):
        '''
        Tranlsate all wireframes on the screen.
        Args:
            :param axis: (str) a string, 'x', 'y', or 'z' indicating the axis to translate
            :param d: (float/int) a value telling how much to translate the specified axis
        '''
        for _, wireframe in self.wireframes.items():
            wireframe.translate(axis, d)

    def scale_all(self, scale):
        '''
        Scale all the wireframes on the the screen.
        Args:
            :param scale: (float) The parameter (scale>1-bigger, scale<1-smaller) telling pygame to scale the wireframes up or down.
        '''
        center_x, center_y = self.width/2, self.height/2
        for _, wireframe in self.wireframes.items():
            wireframe.scale(center_x, center_y, scale)

    def rotate_all(self, axis, theta):
        '''
        Rotate all wireframes in teh screen.
        '''
        rotate_func_name = 'rotate_' + axis

        for _,wireframe in self.wireframes.items():
            center = wireframe.find_center()
            getattr(wireframe, rotate_func_name)(center, theta)

if __name__ == '__main__':
    p = Projector(400, 300)
    cube = wireframe.Wireframe()
    cube.add_nodes([(x,y,z) for x in (50,250) for y in (50,250) for z in (50,250)])
    cube.add_edges([(n,n+4) for n in range(0,4)]+[(n,n+1) for n in range(0,8,2)]+[(n,n+2) for n in (0,1,4,5)])
    p.add_wireframe('cube', cube)
    p.run()


