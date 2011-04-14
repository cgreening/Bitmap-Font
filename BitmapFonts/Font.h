//
//  Font.h
//  Tanks
//
//  Created by Chris Greening on 11/04/2011.
//  Copyright 2011 CMG Research Ltd. All rights reserved.
//
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