#include <GLUT/glut.h>

// to build: clang++ -framework glut -framework opengl -Wno-deprecated /Users/admin/Documents/github/llvmaxe-haxe-llvm/hellogl.c -o a

void display(void) {

    //clear white, draw with black
    glClearColor(255, 255, 255, 0);
    glColor3d(0, 0, 0);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //this draws a square using vertices
    glBegin(GL_QUADS);
    glVertex2i(0, 0);
    glVertex2i(0, 128);
    glVertex2i(128, 128);
    glVertex2i(128, 0);
    glEnd();

    //a more useful helper
    glRecti(200, 200, 250, 250);

    glutSwapBuffers();

}

void reshape(int width, int height) {

    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    //set the coordinate system, with the origin in the top left
    gluOrtho2D(0, width, height, 0);
    glMatrixMode(GL_MODELVIEW);
}

void idle(void) {
    glutPostRedisplay();
}

int main(int argc, char **argv) {

    //a basic set up...
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
    glutInitWindowSize(640, 480);

    //create the window, the argument is the title
    glutCreateWindow("GLUT program");

    //pass the callbacks
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutIdleFunc(idle);

    glutMainLoop();

    //we never get here because glutMainLoop() is an infinite loop
    return 0;

}