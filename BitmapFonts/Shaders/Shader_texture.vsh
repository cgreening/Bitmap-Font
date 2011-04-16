//Copyright 2011 CMG Research Ltd.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

attribute vec4 position;
attribute vec2 texcoord;
uniform mat4 mvp;

varying mediump vec2 v_texcoord;

void main()
{
  gl_Position = mvp * position;
	v_texcoord=texcoord;
}
