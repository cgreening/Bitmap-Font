//
//  Shader.fsh
//  Tutorial6
//
//  Created by Chris Greening on 28/09/2010.
//

varying mediump vec2 v_texcoord;
uniform sampler2D texture;

void main()
{
	gl_FragColor = texture2D(texture, v_texcoord);
}
