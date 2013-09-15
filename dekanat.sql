create table Persons (
    Id int not null,
    FirstName varchar(20) not null,
    LastName varchar(20) not null,
    constraint persons_pk primary key (Id)
);

create table Courses (
    Id int not null,
    Name varchar(50) not null,
    constraint courses_pk primary key (Id)
);

create table Groups (
    Id int not null,
    GroupNo char(4) not null,
    constraint groups_pk primary key (Id)
);

create table CanTeach (
    PersonId int not null,
    CourseId int not null,
    constraint CanTeach_fk1 foreign key (PersonId) references Persons(Id),
    constraint CanTeach_fk2 foreign key (CourseId) references Courses(Id)
);

create table StudentsInGroups (
    PersonId int not null references Persons(Id),
    GroupId int not null references Groups(Id),
    primary key (PersonId)
);

create table CoursesRead (
    Id int not null primary key,
    Year char(4) not null,
    CourseId int not null references Courses(Id)
);

create table CourseReadPerson (
    PersonId int not null references Persons(Id),
    CourseReadId int not null references CoursesRead(Id)
);

create table CourseReadToGroups (
    GroupId int not null references Groups(Id),
    CourseReadId int not null references CoursesRead(Id)
);

create table Marks (
    StudentId int not null,
    ReadCourseId int not null,
    Mark int not null,
    foreign key (StudentId) references Persons(Id),
    foreign key (ReadCourseId) references CoursesRead(Id),
    constraint mark_ok check (Mark <= 5 and Mark > 1)
);

drop table Marks;
drop table CourseReadPerson;
drop table CourseReadToGroups;
drop table CoursesRead;
drop table StudentsInGroups;
drop table CanTeach;
drop table Groups;
drop table Courses;
drop table Persons;
