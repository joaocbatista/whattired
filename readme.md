# What Tired

Simple ODO meter connect IQ datafield.
To track distance per year, month, week, ride, front tyre, back tyre.

# Settings

All values are in kilometers. Fill in a number larger than 0 (no decimals) to set a value.

- Set odo (total km)
- Set max odo (optional)
- Set distance for current:
  - year
  - month
  - week
  - ride
- Set distance for last:
  - year
  - month
  - week
  - ride

Show color: Show a graphical percentage bar current / last.
Show values: Show the actual kilometers.

Optional, track front / back tyre distance.
- Set the amont
- Set the max 
  - Default: 
    - front 9000 km
    - back 3000 km

On a small field, use focus to display only one value.

## Hide/show fields

Set fields to display:
    - O: Odo
    - R: Ride
    - M: Month
    - W: Week
    - Y: Year
    - F: Front
    - B: Back
Default show all fields: OYMWRFB

## Reset Front/Back to 0

Create an activity profile with name `Front` or `Back`, and add/enable this datafield.
When switching to this activity, after 10 beeps the Front or Back counter will reset to 0.


