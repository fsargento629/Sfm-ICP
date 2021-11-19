# Sfm-ICP
Georeferencing algorithm using Structure from Motion (Sfm) and Iterative Closest Point (ICP) for forest fire georeferencing. 

Part of the master thesis I wrote in 2021:

"Georeferencing of Fire front aerial images using Structure from motion and iterative closest point"

Abstract:
This work proposes the use of Structure-from-motion (Sfm) and Iterative Closest Point (ICP) as a
forest fire georeferencing algorithm to be used with images captured by an aerial vehicle. Sfm+ICP uses the real time video captured by an aircraft’s camera, as well as its IMU and GPS measurements to reconstruct a dense 3D point cloud of the disaster area captured by the camera. The Sfm reconstruction is divided in two steps: a sparse reconstruction step using Speeded up robust features (SURF) for camera pose estimation, and a dense reconstruction step relying on a Kanade–Lucas–Tomasi (KLT) feature tracker initialized using the minimum eigenvalue algorithm. This dense 3D reconstruction is then registered to a real Digital Elevation Model (DEM) of the surrounding area, thus refining the point cloud to better match the terrain. The reconstruction is then used as the basis of the georeferencing estimates, as any target’s location can be estimated by averaging the 3D coordinates corresponding to its nearby pixels. The algorithm was validated with two artificial Blender datasets and two real forest fire monitoring
videos. The results demonstrate that Sfm+ICP can perform accurate 3D reconstructions while also georefering several targets in a forest fire environment. The results also show the algorithm is robust to high IMU and GPS errors, making it a far better option than optic-ray-based georeferencing for UAVs with unreliable telemetry.
