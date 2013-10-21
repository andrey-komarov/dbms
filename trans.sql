create table Vertices (
    Id int not null,
    constraint vertices_pk primary key (Id)
);

create table Graph (
    VFrom int not null,
    VTo int not null,
    constraint graph_fk1 foreign key (VFrom) references Vertices(Id),
    constraint graph_fk2 foreign key (VTo) references Vertices(Id)
);

create table Closure (
    VFrom int not null,
    VTo int not null,
    constraint closure_fk1 foreign key (VFrom) references Vertices(Id),
    constraint closure_fk2 foreign key (VTo) references Vertices(Id),
    constraint closure_pk primary key (VFrom, VTo)
);

create function pathToSelf() returns trigger as $$
begin
    insert into Closure(VFrom, VTo) values (new.Id, new.Id);
    return null;
end; $$ language plpgsql;

create function runClosure() returns trigger as $$
begin
    insert into Closure(VFrom, VTo) values (new.VFrom, new.VTo);
    insert into Closure(VFrom, VTo) 
    select P1.VFrom, P2.VTo from Closure P1, Closure P2 
        where P1.VTo = new.VFrom 
            and new.VTo = P2.VFrom 
            and not exists (select (VFrom, VTo) from Closure P3 
                where P3.VFrom = P1.VFrom and P3.VTo = P2.VTo
            );
    return null;
end; $$ language plpgsql;

create trigger Refl after insert on Vertices
    for each row
        execute procedure pathToSelf();

create trigger Trans after insert on Graph
    for each row 
        execute procedure runClosure();

insert into Vertices(Id) values
    (0), (1), (2), (3), (4), (5);

insert into Graph(VFrom, VTo) values
    (0, 1),
    (1, 2),
    (2, 0);

select * from Graph;

select * from Closure;

drop function pathToSelf() cascade;
drop function runClosure() cascade;
drop table Closure;
drop table Graph;
drop table Vertices;
