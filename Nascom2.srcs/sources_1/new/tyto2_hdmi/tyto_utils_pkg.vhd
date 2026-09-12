--------------------------------------------------------------------------------
-- tyto_utils_pkg.vhd                                                         --
-- Useful functions and procedures etc.                                       --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE tyto_utils_pkg IS

  TYPE prng_t IS PROTECTED
    PROCEDURE rand_seed(s1, s2 : IN INTEGER);
    IMPURE FUNCTION rand_real (min, max : IN real) RETURN real;
    IMPURE FUNCTION rand_int (min, max : IN INTEGER) RETURN INTEGER;
    IMPURE FUNCTION rand_slv (min, max, length : IN INTEGER) RETURN STD_ULOGIC_VECTOR;
  END PROTECTED prng_t;

  FUNCTION ternary (c : BOOLEAN; a, b : INTEGER) RETURN INTEGER;
  FUNCTION ternary (c : BOOLEAN; a, b : STD_LOGIC) RETURN STD_LOGIC;
  FUNCTION ternary (c : BOOLEAN; a, b : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;
  FUNCTION bool2sl(b : BOOLEAN) RETURN STD_ULOGIC;
  FUNCTION log2 (x : INTEGER) RETURN INTEGER;
  FUNCTION reverse(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;
  FUNCTION mirror(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;
  FUNCTION add(a, b : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;
  FUNCTION add(a : STD_ULOGIC_VECTOR; b : INTEGER) RETURN STD_ULOGIC_VECTOR;
  FUNCTION sub(a, b : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;
  FUNCTION sub(a : STD_ULOGIC_VECTOR; b : INTEGER) RETURN STD_ULOGIC_VECTOR;
  FUNCTION incr(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;
  FUNCTION decr(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR;

  PROCEDURE fd(
    SIGNAL c : IN STD_ULOGIC;
    SIGNAL d : IN STD_ULOGIC;
    SIGNAL q : OUT STD_ULOGIC
  );

  PROCEDURE fd(
    SIGNAL c : IN STD_ULOGIC;
    SIGNAL d : IN STD_ULOGIC_VECTOR;
    SIGNAL q : OUT STD_ULOGIC_VECTOR
  );

END PACKAGE tyto_utils_pkg;

LIBRARY ieee;
USE ieee.math_real.ALL;

PACKAGE BODY tyto_utils_pkg IS

  TYPE prng_t IS PROTECTED BODY
    VARIABLE seed1, seed2 : INTEGER := 0;
    PROCEDURE rand_seed(s1, s2 : IN INTEGER) IS
    BEGIN
      seed1 := s1;
      seed2 := s2;
    END PROCEDURE rand_seed;
    IMPURE FUNCTION rand_real(min, max : IN real) RETURN real IS
      VARIABLE r : real;
    BEGIN
      uniform(seed1, seed2, r);
      RETURN (r * (max - min)) + min;
    END FUNCTION rand_real;
    IMPURE FUNCTION rand_int(min, max : IN INTEGER) RETURN INTEGER IS
      VARIABLE r : real;
    BEGIN
      uniform(seed1, seed2, r);
      RETURN INTEGER(r * real(max - min) + real(min));
    END FUNCTION rand_int;
    IMPURE FUNCTION rand_slv(min, max, length : IN INTEGER) RETURN STD_ULOGIC_VECTOR IS
      VARIABLE r : real;
    BEGIN
      uniform(seed1, seed2, r);
      RETURN STD_ULOGIC_VECTOR(to_unsigned(INTEGER(r * real(max - min) + real(min)), length));
    END FUNCTION rand_slv;
  END PROTECTED BODY prng_t;

  FUNCTION ternary (c : BOOLEAN; a, b : INTEGER) RETURN INTEGER IS
  BEGIN
    IF c THEN
      RETURN a;
    ELSE
      RETURN b;
    END IF;
  END FUNCTION ternary;

  FUNCTION ternary (c : BOOLEAN; a, b : STD_LOGIC) RETURN STD_LOGIC IS
  BEGIN
    IF c THEN
      RETURN a;
    ELSE
      RETURN b;
    END IF;
  END FUNCTION ternary;

  FUNCTION ternary (c : BOOLEAN; a, b : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    IF c THEN
      RETURN a;
    ELSE
      RETURN b;
    END IF;
  END FUNCTION ternary;

  FUNCTION bool2sl(b : BOOLEAN) RETURN STD_ULOGIC IS
  BEGIN
    IF b THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END FUNCTION bool2sl;

  FUNCTION log2 (x : INTEGER) RETURN INTEGER IS
    VARIABLE i : INTEGER := 0;
  BEGIN
    WHILE 2 ** i < x LOOP
      i := i + 1;
    END LOOP;
    RETURN i;
  END FUNCTION log2;

  FUNCTION reverse(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
    VARIABLE y : STD_ULOGIC_VECTOR(x'reverse_range);
  BEGIN
    FOR i IN x'RANGE LOOP
      y(i) := x(i);
    END LOOP;
    RETURN y;
  END FUNCTION reverse;

  FUNCTION mirror(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
    VARIABLE y : STD_ULOGIC_VECTOR(x'RANGE);
  BEGIN
    FOR i IN x'RANGE LOOP
      y(i) := x(x'high - i);
    END LOOP;
    RETURN y;
  END FUNCTION mirror;

  FUNCTION add(a, b : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(a) + resize(unsigned(b), a'length));
  END FUNCTION add;

  FUNCTION add(a : STD_ULOGIC_VECTOR; b : INTEGER) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(a) + to_unsigned(b, a'length));
  END FUNCTION add;

  FUNCTION sub(a, b : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(a) - resize(unsigned(b), a'length));
  END FUNCTION sub;

  FUNCTION sub(a : STD_ULOGIC_VECTOR; b : INTEGER) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(a) - to_unsigned(b, a'length));
  END FUNCTION sub;

  FUNCTION incr(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(x) + 1);
  END FUNCTION incr;

  FUNCTION decr(x : STD_ULOGIC_VECTOR) RETURN STD_ULOGIC_VECTOR IS
  BEGIN
    RETURN STD_ULOGIC_VECTOR(unsigned(x) - 1);
  END FUNCTION decr;

  PROCEDURE fd(
    SIGNAL c : IN STD_ULOGIC;
    SIGNAL d : IN STD_ULOGIC;
    SIGNAL q : OUT STD_ULOGIC
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(c);
    q <= d;
  END PROCEDURE fd;

  PROCEDURE fd(
    SIGNAL c : IN STD_ULOGIC;
    SIGNAL d : IN STD_ULOGIC_VECTOR;
    SIGNAL q : OUT STD_ULOGIC_VECTOR
  ) IS
  BEGIN
    WAIT UNTIL rising_edge(c);
    q <= d;
  END PROCEDURE fd;

END PACKAGE BODY tyto_utils_pkg;