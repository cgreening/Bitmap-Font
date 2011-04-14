//
//  Shader.vsh
//  Tutorial6
//
//  Created by Chris Greening on 28/09/2010.
//

attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 mvp;

varying mediump vec2 v_texcoord;

void main()
{
  gl_Position = mvp * position;
	v_texcoord=texcoord;
}
