unit FastBoxBlur;

interface

uses gr32;

procedure boxblur(img: tbitmap32; radius: integer; iterations: integer; horz: boolean = true; vert: boolean = true);

implementation

{$R-} //only for our array[0..0] accesses
{$Q-} {not needed, this routine is perfect. Added this to speed things up if the user
       wants global overflow checking.}
       
procedure boxblur(img: tbitmap32; radius: integer; iterations: integer; horz: boolean = true; vert: boolean = true);
var gSum: cardinal; bSum: cardinal; rSum: cardinal; aSum: Cardinal;
  line: PColor32Array;
  col: tcolor32;
  winlength: longword;
  window, cx, x, y, t1, iter: integer;
  realwidth, bytewidth, width, height: integer;
  scanjump: integer;
  rightedge, leftedge, center: PColor32;
  pixelbuf: array of TColor32;
begin
  bytewidth := img.width * 4;
  realwidth := img.width;
  width := img.width - 1;
  height := img.height - 1;
  winlength := radius * 2 + 1;
  scanjump := integer(img.scanline[1]) - integer(img.scanline[0]);

  if horz then begin
    setlength(pixelbuf, img.width);
    for iter := 0 to iterations - 1 do begin
      line := img.scanline[0];

      for y := 0 to height do begin
        rsum := 0;
        gsum := 0;
        bsum := 0;
        aSum := 0;
    //load up our initial window
        for window := -radius to radius - 1 do begin //-1 so we don't include the first pixel to enter the window
          //"Wrap" our edge pixel
          if window < 0 then
            cx := 0 else
            cx := window;

          rSum := rSum + (line[cx]) and $FF;
          gSum := gSum + (line[cx] shr 8) and $FF;
          bSum := bSum + (line[cx] shr 16) and $FF;
          aSum := aSum + (line[cx] shr 24);
        end;

        leftedge := @line[0];
        rightedge := @line[radius]; //start loading pixels in the end of the window
        center := @pixelbuf[0];

        for x := 0 to width do begin
          col := rightedge^; //add the pixel at the right edge of the window
          rSum := rSum + col and $FF;
          gSum := gSum + (col shr 8) and $FF;
          bSum := bSum + (col shr 16) and $FF;
          aSum := aSum + (col shr 24);

          center^ := (bSum div winlength) shl 16 or (gSum div winlength) shl 8 or (rSum div winlength) or (aSum div winlength) shl 24;

      //unload the leftmost pixel
          col := leftedge^;
          rSum := rSum - (col and $FF);
          gSum := gSum - ((col shr 8) and $FF);
          bSum := bSum - ((col shr 16) and $FF);
          aSum := aSum - (col shr 24);

          if x < width - radius then
            inc(rightedge);
          if x >= radius then
            inc(leftedge);
          inc(center);
        end;

        Move(pixelbuf[0], line[0], 4 * (width + 1)); //copy the line we built to the bmp
        line := Pointer(integer(line) + scanjump); //move to next line
      end;
    end; //horz iterations
  end;


  if vert then begin
    setlength(pixelbuf, img.height);
    for iter := 0 to iterations - 1 do begin
      line := img.scanline[0];

      for x := 0 to width do begin
        rsum := 0;
        gsum := 0;
        bsum := 0;
        asum := 0;

    //load up our initial window
        for window := -radius to radius - 1 do begin //-1 so we don't include the first pixel to enter the window
          //"Wrap" our edge pixel
          if window < 0 then
            cx := 0 else
            cx := window;

          rSum := rSum + (line[cx * realwidth]) and $FF;
          gSum := gSum + (line[cx * realwidth] shr 8) and $FF;
          bSum := bSum + (line[cx * realwidth] shr 16) and $FF;
          aSum := aSum + (line[cx * realwidth] shr 24);
        end;

        leftedge := @line[0];
        rightedge := @line[radius * realwidth]; //start loading pixels in the end of the window
        center := @pixelbuf[0];

        for y := 0 to height do begin
          col := rightedge^; //add the pixel at the right edge of the window
          rSum := rSum + col and $FF;
          gSum := gSum + (col shr 8) and $FF;
          bSum := bSum + (col shr 16) and $FF;
          aSum := aSum + (col shr 24);

          center^ := (bSum div winlength) shl 16 or (gSum div winlength) shl 8 or (rSum div winlength) or (asum div winlength) shl 24;

      //unload the leftmost pixel
          col := leftedge^;
          rSum := rSum - (col and $FF);
          gSum := gSum - ((col shr 8) and $FF);
          bSum := bSum - ((col shr 16) and $FF);
          aSum := aSum - (col shr 24);

          if y < height - radius then
            inc(rightedge, realwidth);
          if y >= radius then
            inc(leftedge, realwidth);
          inc(center);
        end;

        leftedge := @pixelbuf[0]; // Input
        rightedge := @line[0]; // Output
        for t1 := 0 to height do begin
          rightedge^ := leftedge^;
          inc(rightedge, realwidth);
          inc(leftedge);
        end;

        inc(line); //move to next col
      end;
    end;
  end;
end;

end.
