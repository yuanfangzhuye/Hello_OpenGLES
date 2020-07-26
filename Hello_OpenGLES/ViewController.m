//
//  ViewController.m
//  Hello_OpenGLES
//
//  Created by 李超 on 2020/7/25.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface ViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *cEffect;
    GLint _angle;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupConfig];
    [self setupVertexData];
    [self setUpTexture];
}

- (void)setupConfig
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"Create ES context Failed");
    }
    
    [EAGLContext setCurrentContext:context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
}

- (void)setupVertexData
{
    GLfloat vertexData[] = {
        0.5f, 0.5f, 0.0f,    1.0f, 1.0f,
        -0.5f, 0.5f, 0.0f,    0.0f, 1.0f,
        -0.5f, -0.5f, 0.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, 0.0f,    1.0f, 1.0f,
        0.5f, -0.5f, 0.0f,    1.0f, 0.0f,
        -0.5f, -0.5f, 0.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, 0.0f,    0.0f, 1.0f,
        0.5f, 0.5f, 0.5f,    1.0f, 1.0f,
        0.5f, -0.5f, 0.5f,    1.0f, 0.0f,
        
        0.5f, 0.5f, 0.0f,    0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,    1.0f, 0.0f,
        0.5f, -0.5f, 0.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, 0.5f,    0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,    0.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,    1.0f, 1.0f,
        
        0.5f, -0.5f, 0.5f,    0.0f, 0.0f,
        -0.5f, 0.5f, 0.5f,    1.0f, 1.0f,
        -0.5f, -0.5f, 0.5f,    1.0f, 0.0f,
        
        -0.5, -0.5, 0.5f,   0.0f, 0.0f,
        -0.5, 0.5, 0.0f,    1.0f, 1.0f,
        -0.5, 0.5, 0.5f,    0.0f, 1.0f,
        
        -0.5, 0.5, 0.0f,    1.0f, 1.0f,
        -0.5, -0.5, 0.0f,    1.0f, 0.0f,
        -0.5, -0.5, 0.5f,   0.0f, 0.0f,
        
        -0.5, 0.5, 0.0f,   0.0f, 0.0f,
        0.5, 0.5, 0.0f,    1.0f, 0.0f,
        0.5, 0.5, 0.5f,    1.0f, 1.0f,
        
        -0.5, 0.5, 0.5f,    0.0f, 1.0f,
        -0.5, 0.5, 0.0f,   0.0f, 0.0f,
        0.5, 0.5, 0.5f,    1.0f, 1.0f,
        
        -0.5, -0.5, 0.5f,   0.0f, 0.0f,
        -0.5, -0.5, 0.0f,    0.0f, 1.0f,
        0.5, -0.5, 0.5f,    1.0f, 0.0f,
        
        -0.5, -0.5, 0.0f,    0.0f, 1.0f,
        0.5, -0.5, 0.5f,    1.0f, 0.0f,
        0.5, -0.5, 0.0f,    1.0f, 1.0f,
    };
    
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0) ;
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)setUpTexture
{
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"png"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:imgPath options:options error:nil];
    
    //3.使用苹果GLKit 提供GLKBaseEffect 完成着色器工作(顶点/片元)
    cEffect = [[GLKBaseEffect alloc]init];
    cEffect.texture2d0.enabled = GL_TRUE;
    cEffect.texture2d0.name = textureInfo.name;
    
    CGFloat aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1f, 100.0f);
    cEffect.transform.projectionMatrix = projectMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self update];
    [cEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void)update
{
    _angle = (_angle + 2) % 360;
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -4);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(_angle));
    cEffect.transform.modelviewMatrix = modelViewMatrix;
    
}

/**
 在 iOS 中，出于性能考虑，所有顶点着色器的属性（Attribute）变量通道都是默认关闭的，这就意味着顶点数据在着色器端（服务端）是不可用的，即使你已经使用 glBufferData 方法，将顶点数据从内存拷贝到顶点缓存区中（GPU显存中）。所以，必须由 glEnableVertexAttribArray 方法打开通道，指定访问属性，才能让顶点着色器能够访问到从 CPU 复制到 GPU 的数据。

 ⚠️注意：数据在 GPU 端是否可见，即着色器能否读取到数据，由是否启用了对应的属性决定，这就是 glEnableVertexAttribArray 的功能，允许顶点着色器读取 GPU（服务器端）数据。

 ```
 glEnableVertexAttribArray(GLKVertexAttribPosition);
 // 上传顶点数据到显存（设置合适的方式从 buffer 里面读取数据）
 //参数1：传递顶点坐标的类型有五种类型：position[顶点]、normal[法线]、color[颜色]、texCoord0[纹理一]、texCoord1[纹理二]，这里用的是顶点类型
 //参数2：每次读取数量（如 position 是由3个（x,y,z）组成，而颜色是4个（r,g,b,a），纹理则是2个）
 //参数3：指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT
 //参数4：指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
 //参数5：步长，取完一次数据需要跨越多少步长去读取下一个数据，如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
 //参数6：指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0。
 glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
 ```

 开辟顶点缓存区

 ```
 //(1).创建顶点缓存区标识符ID
 GLuint bufferID;
 glGenBuffers(1, &bufferID);

 //(2).绑定顶点缓存区.(明确作用)
 glBindBuffer(GL_ARRAY_BUFFER, bufferID);

 //(3).将顶点数组的数据copy到顶点缓存区中(GPU显存中)
 //参数1：目标
 //参数2：坐标数据的大小
 //参数3：坐标数据
 //参数4：用途
 glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
 ```


 ⚠️注意：
 iOS 的坐标计算是从左上角 [0, 0] 开始，到右下角 [1, 1]。但是在文里中的原点不是左上角，而是左下角 [0, 0]，右上角[1, 1]。所以如果想要正确的加载图片，需要设置纹理的原点为左下角。否则得到的图片将会是一张倒立的图片。

 ```
 NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
 GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
 ```
 */


@end
