from pymavlink import mavutil
import time

# === CONFIGURATION ===
TARGET_SYSTEM = 1
TARGET_COMPONENT = 1
MOTOR_NUMBERS = [1, 2, 3, 4]  # Motor index (1-based)
THROTTLE_PERCENT = 10         # Throttle percent (0-100)
DURATION_SEC = 2              # How long to run each motor
MOTOR_TEST_ORDER = 0          # Default motor test sequence
MOTOR_TEST_TYPE = 0           # 0 = throttle percent

# === CONNECT TO VEHICLE ===
print("[INFO] Connecting to ArduPilot...")
master = mavutil.mavlink_connection('udp:127.0.0.1:14550')  # or udp:<pi_ip>:14550 if running on PC
master.wait_heartbeat()
print(f"[INFO] Connected to system {master.target_system}, component {master.target_component}")

# === ARM VEHICLE ===
def arm_vehicle():
    print("[INFO] Arming motors...")
    master.arducopter_arm()
    master.motors_armed_wait()
    print("[INFO] Motors armed.")

# === DISARM VEHICLE ===
def disarm_vehicle():
    print("[INFO] Disarming motors...")
    master.arducopter_disarm()
    master.motors_disarmed_wait()
    print("[INFO] Motors disarmed.")

# === MOTOR TEST ===
def motor_test(motor_number, throttle, duration):
    print(f"[TEST] Motor {motor_number} @ {throttle}% for {duration}s")
    master.mav.command_long_send(
        TARGET_SYSTEM,
        TARGET_COMPONENT,
        mavutil.mavlink.MAV_CMD_DO_MOTOR_TEST,
        0,  # confirmation
        motor_number,        # param1: motor number (1-based)
        MOTOR_TEST_TYPE,     # param2: test type (0 = throttle %, 1 = PWM, etc.)
        throttle,            # param3: throttle %
        duration,            # param4: duration (sec)
        MOTOR_TEST_ORDER,    # param5: motor sequence order (0 = default)
        0, 0                 # param6-7: unused
    )
    time.sleep(duration + 1)

# === MAIN SEQUENCE ===
try:
    arm_vehicle()
    time.sleep(1)

    for motor in MOTOR_NUMBERS:
        motor_test(motor, THROTTLE_PERCENT, DURATION_SEC)
        time.sleep(2)

finally:
    disarm_vehicle()
