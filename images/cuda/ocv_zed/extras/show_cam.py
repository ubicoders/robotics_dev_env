import numpy as np
import cv2
import pyzed.sl as sl
import time
np.set_printoptions(suppress=True, precision=3)

def orb_vo_main():
   
    zed = sl.Camera()
    init_params = sl.InitParameters()
    init_params.camera_resolution = sl.RESOLUTION.HD720
    init_params.camera_fps = 60
    init_params.depth_mode = sl.DEPTH_MODE.NEURAL_LIGHT

    if zed.open(init_params) != sl.ERROR_CODE.SUCCESS:
        print("Failed to open the ZED camera", flush=True)
        return

    image_left = sl.Mat()
    image_right = sl.Mat()
    runtime_parameters = sl.RuntimeParameters()

    seq = 0
    index = 0    
   
    while True:
        tic = time.time()
        if zed.grab(runtime_parameters) == sl.ERROR_CODE.SUCCESS:
            zed.retrieve_image(image_left, sl.VIEW.LEFT)
            zed.retrieve_image(image_right, sl.VIEW.RIGHT)
            imgl_curr = image_left.get_data()
            imgr_curr = image_right.get_data()

            cv2.imshow('Left', imgl_curr)  
            cv2.imshow('Right', imgr_curr)

            # Print every 10 frames to reduce main thread overhead
            if index % 10 == 0:
                print(f"Main thread: Captured frame {index}", flush=True)
            index += 1
            
            toc = time.time()
            print(f"dT = {toc - tic:.3f}, FPS = {1/(toc - tic):.1f}", flush=True)

        key = cv2.waitKey(1)
        if key == 27 or key == ord('q'):
            print("Quit key pressed, shutting down...", flush=True)
            break


    zed.close()

    print("Main thread: Shutdown complete", flush=True)

if __name__ == "__main__":
    orb_vo_main()