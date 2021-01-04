// Side to side width of the rack
length = 100;

// Max height of each section divider
height = 60;

// Angle of the divider. Keep it steep to print without supports.
angle = 60;

// Number of devices to hold
num_devices = 3;

// Size in mm of each device to hold. Must match num_devices. Allow ~1mmmm so it's not too tight.
widths = [16, 16, 28];

// Thickness of the parts. I don't recommend changing this.
thickness = 8;


// find the sublist of 'list' with indices from 'from' to 'to' 
function sublist(list, from=0, to) =
    let( end = (to==undef ? len(list)-1 : to) )
    [ for(i=[from:end]) list[i] ];

// sum all the items in a sublist
function add(v, i = 0, r = 0) = i < len(v) ? add(v, i + 1, r + v[i]) : r;

// Distances at which to place the dividers. This is calculated by doing adding all elements oof each sublist in widths. This is way more complicated than it should be, but I could not find a simpler way.

count = num_devices <  len(widths) ? num_devices : len(widths);
   
distances = [for (idx = [ 0 : count - 1 ] ) add(sublist(widths, 0, idx)) + (thickness * (idx+1)) ];  
  


module oval(w,h, height, center = false) {
 scale([1, h/w, 1]) cylinder(h=height, r=w, center=center);
}


/**
 * The angled part and the foot of a section divider.
 *
 * This is composed of bar rotated vertically by angle, a top hat that closes it on top, and
 * a foot that extends out to cmplete length/2
 */
module half_divider() {
    //                  /|
    //  c              / | a (height) 
    // (length)       /  |
    //               /   |
    //               -----
    //            b (width)
    
    // top hat: closes the arm at the top so it has a flat top
    //hat_width = thickness * sin(angle);
    hat_height = thickness * cos(angle) * 2;
    
    // Adjust the arm height to account to for the top hat
    calc_height = height - hat_height;
    
    top_hat();
    
    // Hypotenuse of the triangle rectangle
    arm_length = calc_height / sin(angle);
    
    // Base of the triangle rectangle
    base = arm_length * sin(90-angle);
    
    translate([-base, 0, 0])         
    rotate([0, -angle, 0])
    cube([arm_length, thickness, thickness]);
    
    foot_length = (length/2) - base;
    translate([-base - foot_length, 0, 0]) cube([foot_length, thickness, thickness]);
}

module top_hat() {
    
    // top hat: closes the arm at the top so it has a flat top
    hat_width = thickness * sin(angle);
    hat_height = thickness * cos(angle) * 2;
    
    // Adjust the arm height to account to for the top hat
    calc_height = height - hat_height;
    
    // Hypotenuse of the triangle rectangle
    arm_length = calc_height / sin(angle);
    
    // Base of the triangle rectangle
    base = arm_length * sin(90-angle);
  
    intersection() {
        translate([-hat_width, 0, calc_height]) cube([hat_width, thickness, hat_height]);
        
        translate([-base, 0, 0])         
        rotate([0, -angle, 0])
        cube([arm_length * 4, thickness, thickness]);
    }
    
}

/**
 * Build the sidebar
 *
 * Horizontal bar that joins the dividers together and with wires cutout in the middle of each hole
 */
module sidebar() {
     difference() {
        
        // A long bar that cuts across the feet of the dividers
        translate([-length/2, 0, 0]) cube([thickness, distances[len(distances) - 1]+thickness, thickness]);
        
        // Each cutout is a bar rotated 45 degrees lenghtwise, and translated down on Z so only the top part cuts the sidebar
        union() {
            for (idx = [ 0 : len(distances) - 1 ] ) {        
                distance = distances[idx];
                width = widths[idx];
                translate([-length/2-1, distance - width/2, -4]) rotate([0, 90, 0]) oval(thickness, 4.1, thickness + 2);
                //cube([thickness +2, thickness, thickness]); 
            }
        }   
         
     }
}


module half_rack() {
    // lay out the dividers
    half_divider();    
    for (idx = [ 0 : len(distances) - 1 ] ) {        
        distance = distances[idx];
        translate([0, distance, 0]) half_divider();
    }    
    // add the sidebar
    sidebar();
}


union() {
    half_rack();
    mirror([1, 0, 0]) half_rack();
}


