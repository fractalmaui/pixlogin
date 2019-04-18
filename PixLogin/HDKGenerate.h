//
//   _   _ ____  _  ______                           _
//  | | | |  _ \| |/ / ___| ___ _ __   ___ _ __ __ _| |_ ___
//  | |_| | | | | ' / |  _ / _ \ '_ \ / _ \ '__/ _` | __/ _ \
//  |  _  | |_| | . \ |_| |  __/ | | |  __/ | | (_| | ||  __/
//  |_| |_|____/|_|\_\____|\___|_| |_|\___|_|  \__,_|\__\___|
//
//  HDKGenerate (pulled from HDKGenerator)
//  HuedokuPix
//
//  Created by Dave Scruton on 8/1/15.
//  Copyright (c) 2015 huedoku, inc. All rights reserved.
//
//  NOTE!!! all properties with pointers MUST BE CAST strong!
//             otherwise the code runs but krashes!

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BIGGEST_PUZZLE 21
#define MAX_HDKGEN_COLORS 21*21
#define MAX_REF_ARRAY 256
#define BIGGEST_GAMESIZE_XY 64
@interface HDKGenerate : NSObject
{
    UIColor  *colorz[MAX_HDKGEN_COLORS];  //overdimensioned!
    int referenceArrayUp;
    double referenceArray[MAX_REF_ARRAY];
    int rgbarray[BIGGEST_PUZZLE][BIGGEST_PUZZLE][3];
   // UIColor* c[BIGGEST_PUZZLE][BIGGEST_PUZZLE];
    const CGFloat* tlcomponents;
    const CGFloat* trcomponents;
    const CGFloat* blcomponents;
    const CGFloat* brcomponents;
    const CGFloat* rgbcomponents;
    double inv255;
    NSArray *LABtlcorner;
    NSArray *LABtrcorner;
    NSArray *LABblcorner;
    NSArray *LABbrcorner;
    
    UIImage *tlcorn;
    UIImage *trcorn;
    UIImage *blcorn;
    UIImage *brcorn;

    
    NSArray *LAB;

    double LAB_Array[4];
    double LABtl_Array[4];
    double LABtr_Array[4];
    double LABbl_Array[4];
    double LABbr_Array[4];
    
    double solvedRGB[4];
    
    double finalColorz[MAX_HDKGEN_COLORS][3]; //up to 7x7 array here...
    int preScrambled;
    int randhash[BIGGEST_GAMESIZE_XY]; //DHS 8/18 should match MAX_EBOXES in main

}

@property (nonatomic , assign) int       xsize;
@property (nonatomic , assign) int       ysize;
@property (nonatomic , assign) int       difficulty;
@property (nonatomic , strong) UIColor*  tlColor;
@property (nonatomic , strong) UIColor*  trColor;
@property (nonatomic , strong) UIColor*  blColor;
@property (nonatomic , strong) UIColor*  brColor;
@property (nonatomic , assign) double    HCval;
@property (nonatomic , assign) double    LPval;
@property (nonatomic , assign) double    RGval;
@property (nonatomic , assign) double    YBval;


- (UIColor *)colorFromHexString : (NSString *)hexStr;
-(void) createRandHash : (int) size;
-(int)  getRandHashAtIndex : (int) index;
- (UIColor *)colorFromHexString : (NSString *)hexStr;

-( const CGFloat *) getColorRefs : (int) which;
-(UIColor *) getColor: (int) which;
-(void) generateZachArray;
-(void) generateZachArray2;
-(double) getColorTetraVolume;
-(void) loadCurrentGuess : (int) guess;
-(UIImage *) makeBitmapFromPuzzle : (int) bmpsize : (int) xys : (int) diff :
                    (UIColor *) tlc : (UIColor *) trc : (UIColor *) blc : (UIColor *) brc;
-(UIImage *) makeBitmapFromPuzzleInfo : (int) bmpSize : (NSString*)pi;
-(UIImage *) makeBitmap : (int) bmpSize;
-(UIImage *) makeJiggleyBitmapWithPhoto : (int) bmpSize : (UIImage *)photo;
-(void) setColor : (int) which : (UIColor *) color;
-(void) setTLHex : (NSString *) hexstr;
-(void) setTRHex : (NSString *) hexstr;
-(void) setBLHex : (NSString *) hexstr;
-(void) setBRHex : (NSString *) hexstr;
-(void) setPuzzlePreScrambled : (int) newval;
-(void) setRandSeed : (int) seed;
-(void) setRandHash : (int) index : (int) val;
-(void) setupPuzzle : (int) xys : (int) diff : (UIColor *) tlc : (UIColor *) trc : (UIColor *) blc : (UIColor *) brc ;
-(void) setupPuzzleFromPuzzleInfo: (NSString*) pinfo;
-(void) dump;



@end
