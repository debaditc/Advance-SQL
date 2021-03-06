/**************************************************************
  EXAMPLE : Airline flights
  Find cheapest way to fly from 'A' to 'B'
**************************************************************/

/*** Use SQL Lite to run the below commands ***/
create table Flight(orig text, dest text, airline text, cost int);

insert into Flight values ('A', 'ORD', 'United', 200);
insert into Flight values ('ORD', 'B', 'American', 100);
insert into Flight values ('A', 'PHX', 'Southwest', 25);
insert into Flight values ('PHX', 'LAS', 'Southwest', 30);
insert into Flight values ('LAS', 'CMH', 'Frontier', 60);
insert into Flight values ('CMH', 'B', 'Frontier', 60);
insert into Flight values ('A', 'B', 'JetBlue', 195);

/*** First find all costs ***/

with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B';

/*** Then find minimum; note returns cheapest cost but not route ***/

with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest = 'B';
/*** just added min in the above query ***/


/*** Alternative formuation tied specifically to origin 'A' ***/
/*** Filtering in the recursion step itself - where origin = A ***/
with recursive
  FromA(dest,total) as
    (select dest, cost as total from Flight where orig = 'A'
     union
     select F.dest, cost+total as total
     from FromA FA, Flight F
     where FA.dest = F.orig)
select * from FromA;

with recursive
  FromA(dest,total) as
    (select dest, cost as total from Flight where orig = 'A'
     union
     select F.dest, cost+total as total
     from FromA FA, Flight F
     where FA.dest = F.orig)
select min(total) from FromA where dest = 'B';

/*** Alternative formuation tied specifically to destination 'B' ***/

with recursive
  ToB(orig,total) as
    (select orig, cost as total from Flight where dest = 'B'
     union
     select F.orig, cost+total as total
     from Flight F, ToB TB
     where F.dest = TB.orig)
select * from ToB;

with recursive
  ToB(orig,total) as
    (select orig, cost as total from Flight where dest = 'B'
     union
     select F.orig, cost+total as total
     from Flight F, ToB TB
     where F.dest = TB.orig)
select min(total) from ToB where orig = 'A';

/*** Add flight that creates a cycle ***/
/*** Now this creates a cycle and will result in infinite loop. So all above query wont reach destination ***/

insert into Flight values ('CMH', 'PHX', 'Frontier', 80);

/*** Now all queries loop indefinitely ***/
/*** Infinite loop and will result nothing ***/
with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B';

/*** Try only adding cheaper routes ***/

with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig
     and cost+total < all (select total from Route R2
                           where R2.orig = R.orig and R2.dest = F.dest))
select * from Route
where orig = 'A' and dest = 'B';

/*** Limit number of results; doesn't work when min() is added ***/

with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B' limit 20;

/*** We use limit function to stop iteration at 20th time. But it might happen that our result would have appeared at
     26th iteration. So limiting 20 will result wrong output ***/
with recursive
  Route(orig,dest,total) as
    (select orig, dest, cost as total from Flight
     union
     select R.orig, F.dest, cost+total as total
     from Route R, Flight F
     where R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest = 'B' limit 20;

/*** Enforce maximum length of route ***/
/*** Avoid limit constraints and use length. There is still a constraint but no person will travel from A to B via 
     100 flights . so we compare the length less than 100 ***/
with recursive
  Route(orig,dest,total,length) as
    (select orig, dest, cost as total, 1 from Flight
     union
     select R.orig, F.dest, cost+total as total, R.length+1 as length
     from Route R, Flight F
     where R.length < 100 and R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B';

with recursive
  Route(orig,dest,total,length) as
    (select orig, dest, cost as total, 1 from Flight
     union
     select R.orig, F.dest, cost+total as total, R.length+1 as length
     from Route R, Flight F
     where R.length < 10 and R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest = 'B';

/*** Limit - 100000 wont affect much in the query. As, compiler knows how many times to iterate [it has an aim :)] ***/ 
with recursive
  Route(orig,dest,total,length) as
    (select orig, dest, cost as total, 1 from Flight
     union
     select R.orig, F.dest, cost+total as total, R.length+1 as length
     from Route R, Flight F
     where R.length < 100000 and R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest = 'B';

