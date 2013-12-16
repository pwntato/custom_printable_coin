$fn = 20;

front_file = "front.dxf";
back_file = "back.dxf";

coin_d = 40.0;
coin_total_thickness = 5.0;
coin_raised_thickness = 1.0;
coin_rim_w = 1.2;

fudge = 0.01;

octagon_d_to_side_ratio = 2.414;

translate([0, coin_total_thickness / 2.0, coin_d / 2.0])
	rotate([90, 0, 0])
		coin();

module coin() {
	union() {
		difference() {
			translate([0, 0, coin_total_thickness]) {
				rotate([0, 180, 0]) {
					union() {
						difference() {
							octagon(coin_d, coin_total_thickness);

							translate([0, 0, coin_total_thickness - coin_raised_thickness + fudge])
								inset_cutter();
						}

						translate([0, 0, coin_total_thickness - coin_raised_thickness])
							printable_extrude(back_file, coin_raised_thickness);
					}
				}
			}

			translate([0, 0, coin_total_thickness - coin_raised_thickness + fudge])
				inset_cutter();
		}

		translate([0, 0, coin_total_thickness - coin_raised_thickness])
			printable_extrude(front_file, coin_raised_thickness);
	}
}

module printable_extrude(dxf_path, thickness) {
	translate([0, 0, -(thickness + fudge) - fudge]) {
		difference() {
			minkowski() {
				translate([-coin_d / 2.0, -coin_d / 2.0, 0])
					linear_extrude(height=thickness + fudge)
						import(dxf_path);
	
				cylinder(thickness + fudge, thickness, 0);
			}

			translate([-coin_d / 2.0, -coin_d / 2.0, -fudge])
				cube([coin_d, coin_d, thickness + (2 * fudge)]);
		}
	}
}

module inset_cutter() {
	cutter_d = (coin_d - (2 * coin_rim_w));

	difference() {
		octagon(cutter_d, coin_raised_thickness + fudge);

		for(angle=[0:360/8.0:360]) {
			rotate([0, 0, angle]) {
				translate([-cutter_d / 2.0, -cutter_d / 2.0, 0]) {
					rotate([0, 90, 0]) {
						translate([-coin_raised_thickness + (2 * fudge), 
								-(2 * fudge), -(2 * fudge)]) {
							linear_extrude(height=cutter_d)
								polygon([
										[-fudge, -fudge],
										[coin_raised_thickness + (2 * fudge), 
												coin_raised_thickness + (2 * fudge)],
										[coin_raised_thickness + (2 * fudge), -fudge],
									]);
						}
					}
				}
			}
		}
	}
}

module octagon(diameter, thickness) {
	side_length = diameter / octagon_d_to_side_ratio;
	corner_length = side_length / sqrt(2);

	translate([-diameter / 2.0, -diameter / 2.0, 0]) {
		linear_extrude(height=thickness)
			polygon([
					[corner_length, 0],
					[corner_length + side_length, 0],
					[diameter, corner_length],
					[diameter, corner_length + side_length],
					[corner_length + side_length, diameter],
					[corner_length, diameter],
					[0, corner_length + side_length],
					[0, corner_length],
				]);
	}
}




