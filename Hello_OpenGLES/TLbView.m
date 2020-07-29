//
//  TLbView.m
//  Hello_OpenGLES
//
//  Created by tlab on 2020/7/28.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "TLbView.h"
#import <OpenGLES/ES2/gl.h>

@interface TLbView ()

@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
@property (nonatomic, strong) EAGLContext *myContext;

@property (nonatomic, assign) GLuint myColorRenderBuffer;
@property (nonatomic, assign) GLuint myColorFrameBuffer;

@property(nonatomic, assign) GLuint myPrograme;

@end

@implementation TLbView

- (void)layoutSubviews
{
    //1.设置图层
    [self setupLayer];
    
    //2.设置图形上下文
    [self setupContext];
    
    //3.清空缓存区
    [self deleteRenderAndFrameBuffer];

    //4.设置RenderBuffer
    [self setupRenderBuffer];
    
    //5.设置FrameBuffer
    [self setupFrameBuffer];
    
    //6.开始绘制
    [self renderLayer];
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false,kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"创建失败");
        return;
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置上下文失败");
        return;
    }
    
    self.myContext = context;
}

- (void)deleteRenderAndFrameBuffer
{
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
}

- (void)setupRenderBuffer
{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    
    self.myColorRenderBuffer = buffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

- (void)setupFrameBuffer
{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    
    self.myColorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)renderLayer
{
    glClearColor(0.3f, 0.4f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    self.myPrograme = [self loadShaders:vertFile withFrag:fragFile];
    
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    
    NSLog(@"Program Link Success!");
    
    glUseProgram(self.myPrograme);
    
    //倒置的纹理坐标
    GLfloat attrArr[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,

        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    //正确的纹理坐标
//    GLfloat attrArr[] = {
//        0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 1.0f,
//
//        0.5f, 0.5f, -1.0f,      1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 1.0f,
//    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfixed) * 5, NULL);
    
    GLuint textCoor = glGetAttribLocation(self.myPrograme, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    [self setupTexture:@"timg"];
    glUniform1i(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:@"timg"].CGImage;
    if (!spriteImage) {
        NSLog(@"获取图片失败");
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
//    [self rotateTextureImage];
    
//    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
//    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
//    CGContextScaleCTM(spriteContext, 1.0f, -1.0f);
//    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
    
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    CGContextRelease(spriteContext);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    
    return 0;
}

//翻转矩阵
- (void)rotateTextureImage
{
    GLuint rotate = glGetUniformLocation(self.myPrograme, "rotateMatrix");
    
    float radians = 180 * 3.14159f / 180.0f;
    
    float s = sin(radians);
    float c = cos(radians);
    
    GLfloat zRotation[16] = {
        c,-s,0,0,
        s,c,0,0,
        0,0,1,0,
        0,0,0,1
    };
    
    glUniformMatrix4fv(rotate, 1, GL_FALSE, zRotation);
}

#pragma mark ---- Shader

- (GLuint)loadShaders:(NSString *)vert withFrag:(NSString *)frag
{
    GLuint vertShader, fragShader;
    
    GLuint program = glCreateProgram();
    
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}


@end
