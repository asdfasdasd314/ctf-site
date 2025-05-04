INSERT INTO exercises (category, title, difficulty, flag, points, description, tags)
VALUES(
    'web',
    'Vulnerable Authentication',
    'easy',
    'flag{$3CuR3_@uTh_!$_1mP0r+@n+!_iwfNGwv2WAUBLhve}',
    100,
    'Exploit the vulnerable authentication system to get the flag',
    'authentication,web-exploitation'
);

INSERT INTO exercises (title, description, flag, points, category, difficulty, tags)
VALUES (
    'Misdirection',
    'The page redirects too fast to get the flag!',
    'flag{l34rn_t0_cur1_fvSUQMQUJ0gVF547}',
    100,
    'web',
    'easy',
    'http,curl,web-exploitation'
);

INSERT INTO exercises(title, description, flag, points, category, difficulty, tags)
VALUES(
    'Adblocker',
    'Your adblocker is blocking the flag!',
    'flag{ju57_7urn_0ff_4dbl0ck_Gn0gH71XpVw0CuQr}',
    100,
    'web',
    'easy',
    'adblocker,web-exploitation'
);