// OpenSCAD Test File
// This file tests your OpenSCAD + VS Code setup
// Try editing values and saving - the preview should auto-reload!

// Parameters (try changing these!)
cube_size = 30;
hole_radius = 10;
sphere_radius = 8;
sphere_height = 20;

// Main model
difference() {
    // Main cube
    cube([cube_size, cube_size, cube_size], center=true);

    // Cylindrical hole through the cube
    cylinder(h=cube_size*2, r=hole_radius, center=true, $fn=50);
}

// Sphere on top
translate([0, 0, sphere_height])
    sphere(r=sphere_radius, $fn=50);

// Instructions:
// 1. Click "Preview in OpenSCAD" button (top right) to open preview
// 2. Change cube_size to 50 and save - watch preview update!
// 3. Change hole_radius to 15 and save
// 4. Click "Export Model" to save as STL
