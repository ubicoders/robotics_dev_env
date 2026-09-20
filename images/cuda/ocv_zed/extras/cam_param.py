import cv2
import pyzed.sl as sl
import time
import numpy as np  
np.set_printoptions(suppress=True, precision=3)

# Global list to store clicked points
clicked_points = []

# Mouse callback function
def mouse_callback(event, x, y, flags, param):
    if event == cv2.EVENT_LBUTTONDOWN:
        clicked_points.append((x, y))

def main():
    # Create a Camera object
    zed = sl.Camera()

    # Create a Configuration Parameters object
    init_params = sl.InitParameters()
    init_params.camera_resolution = sl.RESOLUTION.HD720  # Use HD1080 video mode
    init_params.camera_fps = 30  # Set FPS at 30

    # Open the camera
    if zed.open(init_params) != sl.ERROR_CODE.SUCCESS:
        print("Failed to open the ZED camera")
        return
    calibration_params = zed.get_camera_information().camera_configuration.calibration_parameters
    # Focal length of the left eye in pixels
    fxl = calibration_params.left_cam.fx
    fyl = calibration_params.left_cam.fy
    cxl = calibration_params.left_cam.cx
    cyl = calibration_params.left_cam.cy

    # right cam
    fxr = calibration_params.right_cam.fx
    fyr = calibration_params.right_cam.fy
    cxr = calibration_params.right_cam.cx
    cyr = calibration_params.right_cam.cy

    # right cam
    tx = calibration_params.stereo_transform.get_translation().get()[0]
    ty = calibration_params.stereo_transform.get_translation().get()[1]
    tz = calibration_params.stereo_transform.get_translation().get()[2]

    # Left camera matrix, Kl
    Kl = np.array([[fxl, 0, cxl],
                   [0, fyl, cyl],
                   [0, 0, 1]])  
    # Right camera matrix, Kr
    Kr = np.array([[fxr, 0, cxr],
                   [0, fyr, cyr],
                   [0, 0, 1]])
    
    # [R|T] matrix for the stereo camera
    Rt = np.array([[1, 0, 0, tx/1000.0],
                   [0, 1, 0, ty],
                   [0, 0, 1, tz]])
    
    print("Rt:")
    print(Rt)
    
    # left camera parameter matrix 
    Pl = Kl @ np.eye(3, 4)  
    # right camera parameter matrix
    Pr = Kl @ Rt

    print("Left Camera Matrix:")
    print(Pl)
    print("Right Camera Matrix:")
    print(Pr)



    



if __name__ == "__main__":
    main()