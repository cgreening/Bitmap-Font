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

#ifndef FONT_H_
#define FONT_H_

#include <string>
#include <map>

class Character {
public:
  Character() : x(0),y(0),width(0),height(0),xOffset(0),yOffset(0),xAdvance(0) {};
	// X location on the spritesheet
	int x;
	// Y location on the spritesheet
	int y;
	// Width of the character image
	int width;
	// Height of the character image
	int height;
	// The X amount the image should be offset when drawing the image
	int xOffset;
	// The Y amount the image should be offset when drawing the image
	int yOffset;
	// The amount to move the current position after drawing the character
	int xAdvance;
};

class Font {
private:
  void parseCharacter(const std::string &line);
  void parseKerningEntry(const std::string &line);
  void parseCommonLine(const std::string &line);
  
  std::map<int, Character> characters;
  std::map<int, std::map<int, int> > kerning;
  int scaleW;
  int scaleH;
  int lineHeight;
public:
  int createVerticesAndTexCoordsForString(const std::string &str, float **verticesAndTexCoords, uint16_t **indices, float height);
  float getWidthOfString(const std::string &str, float height);
  Font(const std::string &fontFile);
};

#endif