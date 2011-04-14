//
//  Font.cpp
//  Tanks
//
//  Created by Chris Greening on 11/04/2011.
//  Copyright 2011 CMG Research Ltd. All rights reserved.
//

#include "Font.h"
#include <fstream>
#include <sstream>
#include <vector>

void split(const std::string &s, char delim, std::vector<std::string> &elems) {
  std::stringstream ss(s);
  std::string item;
  while(std::getline(ss, item, delim)) {
    elems.push_back(item);
  }
}

bool stringStartsWith(const char *prefix, const char *str) {
  return strncmp(prefix, str, strlen(prefix))==0;
}

void Font::parseCharacter(const std::string &line) {
  std::vector<std::string> components;
  split(line, '=', components);
  int charId = atoi(components[1].c_str());
  characters[charId].x = atoi(components[2].c_str());
  characters[charId].y = atoi(components[3].c_str());
  characters[charId].width = atoi(components[4].c_str());
  characters[charId].height = atoi(components[5].c_str());
  characters[charId].xOffset = atoi(components[6].c_str());
  characters[charId].yOffset = atoi(components[7].c_str());
  characters[charId].xAdvance = atoi(components[8].c_str());
}

void Font::parseKerningEntry(const std::string &line) {
  std::vector<std::string> components;
  split(line, '=', components);

  int firstChar = atoi(components[1].c_str());
	int secondChar = atoi(components[2].c_str());
  kerning[firstChar][secondChar] = atoi(components[3].c_str());
}

void Font::parseCommonLine(const std::string &line) {
  std::vector<std::string> components;
  split(line, '=', components);
  lineHeight = atoi(components[1].c_str());
  scaleW = atoi(components[3].c_str());
  scaleH = atoi(components[4].c_str());
}

Font::Font(const std::string &fontFile) {
  // read in the font data
  std::ifstream inFile(fontFile.c_str());
  std::string line;
  while(getline(inFile, line)) {
    // ignore these lines
    if(stringStartsWith("chars c", line.c_str())) continue;
    // ignore this - we don't need it
    if(stringStartsWith("kernings count", line.c_str())) continue;
    // this is a character definition
    if(stringStartsWith("char", line.c_str())) {
      parseCharacter(line);
      continue;
    }
    // kerning info
    if(stringStartsWith("kerning first", line.c_str())) {
      parseKerningEntry(line);
    }
    if(stringStartsWith("common", line.c_str())) {
      parseCommonLine(line);
    }
  }
}

typedef struct {
	float vtlx,vtly,  ttlx,ttly, vblx,vbly,  tblx,tbly, vbrx,vbry,  tbrx,tbry, vtrx,vtry,  ttrx,ttry;
} font_square_t;

#define MAKE_SQUARE_T(x1,y1,x2,y2, tx1, ty1, tx2, ty2) { \
(x1),(y1), (tx1),(ty1), \
(x1),(y2), (tx1),(ty2), \
(x2),(y2), (tx2),(ty2), \
(x2),(y1), (tx2),(ty1) \
}

int Font::createVerticesAndTexCoordsForString(const std::string &str, float **verticesAndTexCoords, uint16_t **indices, float height) {
  float scale=height/(float)lineHeight;
  font_square_t *charSquares = (font_square_t *) malloc(sizeof(font_square_t)*str.size());
  *indices = (uint16_t *) malloc(sizeof(uint16_t)*str.size()*6);
  int index=0;
  float x=0;
  int y=0;
  for(int i=0; i<str.size(); i++) {
    int c = str[i];
    if(i>0) {
      x += scale*((float) kerning[c][str[i-1]]);
    }
    const Character &cdef = characters[c];
    font_square_t tmp = MAKE_SQUARE_T(x+cdef.xOffset*scale, y+scale*(cdef.yOffset), 
                                      x+scale*(cdef.xOffset+cdef.width), y+scale*(cdef.yOffset+cdef.height),
                                      (float) cdef.x/(float) scaleW, (float) cdef.y/(float) scaleH,
                                      (float) (cdef.x+cdef.width)/(float) scaleW, (float) (cdef.y+cdef.height)/(float) scaleH);
    
    charSquares[i]=tmp;
    x+=scale * (float) cdef.xAdvance;

    (*indices)[index]=i*4;
    (*indices)[index+1]=i*4+1;
    (*indices)[index+2]=i*4+2;
    (*indices)[index+3]=i*4+2;
    (*indices)[index+4]=i*4+3;
    (*indices)[index+5]=i*4;
    index+=6;
  }
  *verticesAndTexCoords=(float *) charSquares;
  return index;
}

float Font::getWidthOfString(const std::string &str, float height) {
  int x=0;
  for(int i=0; i<str.size(); i++) {
    int c = str[i];
    if(i>0) {
      x += kerning[c][str[i-1]];
    }
    const Character &cdef = characters[c];
    x+=cdef.xAdvance;
  }
  return x*height/(float) lineHeight;
}
