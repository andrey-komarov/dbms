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
    CourseId int not null references Courses(Id),
    WhoTaughtCourse int not null,
    GroupTaughtCourseTo int not null
);

create table CourseReadPerson (
    Id int not null primary key,
    PersonId int not null references Persons(Id),
    CourseReadId int not null references CoursesRead(Id)
);

create table CourseReadToGroups (
    Id int not null primary key,
    GroupId int not null references Groups(Id),
    CourseReadId int not null references CoursesRead(Id)
);

alter table CoursesRead add constraint CoursesRead_fk1
    foreign key (WhoTaughtCourse) references CourseReadPerson(Id);
alter table CoursesRead add constraint CoursesRead_fk2
    foreign key (GroupTaughtCourseTo) references CourseReadToGroups(Id);

create table Marks (
    StudentId int not null,
    ReadCourseId int not null,
    Mark int not null,
    foreign key (StudentId) references Persons(Id),
    foreign key (ReadCourseId) references CoursesRead(Id),
    constraint mark_ok check (Mark <= 5 and Mark > 1)
);

begin transaction;

insert into Persons (Id, FirstName, LastName) values
    (1, 'Андрей', 'Комаров'),
    (2, 'Сергей', 'Мельников'),
    (3, 'Георгий', 'Корнеев');

insert into Groups (Id, GroupNo) values
    (1, '4538'),
    (2, '6538');

insert into Courses (Id, Name) values
    (1, 'Введение в системы баз данных'),
    (2, 'Компьютерные сети');

insert into CanTeach (PersonId, CourseId) values
    (2, 2),
    (3, 1);

insert into StudentsInGroups (PersonId, GroupId) values
    (1, 1),
    (2, 2);

insert into CoursesRead (Id, Year, CourseId, WhoTaughtCourse, GroupTaughtCourseTo) values
    (1, '2013', 1, 1, 1);

insert into CourseReadToGroups (Id, GroupId, CourseReadId) values
    (1, 1, 1);

insert into CourseReadPerson (Id, PersonId, CourseReadId) values
    (1, 3, 1);

insert into Marks (StudentId, ReadCourseId, Mark) values
    (1, 1, 5);

commit;

alter table CoursesRead drop constraint CoursesRead_fk1;
alter table CoursesRead drop constraint CoursesRead_fk2;

drop table Marks;
drop table CourseReadPerson;
drop table CourseReadToGroups;
drop table CoursesRead;
drop table StudentsInGroups;
drop table CanTeach;
drop table Groups;
drop table Courses;
drop table Persons;
