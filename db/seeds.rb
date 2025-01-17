# Load this data into the database using `db:seed` or `db:setup`.

c1 = Course.find_or_create_by(name: 'Minor Programmeren', slots: 4, minimum: 60, location: "A1.22")
c2 = Course.find_or_create_by(name: 'Programmeren IK', slots: 4, minimum: 60, location: "A1.22")

this_week = Date.current.cweek
this_year = Date.current.year

next_week = (Date.current + 7).cweek
next_year = (Date.current + 7).year # this is not really next year, but next week's year

# ruby weekdays start at Monday = 1
slots = {
    1 => {        # Monday
        9 => 1,
        10 => 1,
        11 => 2,
        12 => 2,
        13 => 1
    },
    2 => {        # Tuesday
        9 => 1,
        10 => 1,
        11 => 2,
        12 => 2,
        13 => 1
    },
    3 => {        # Wednesday
        9 => 1,
        10 => 1,
        11 => 2,
        12 => 2,
        13 => 1
    },
    4 => {        # Thursday
        9 => 1,
        10 => 1,
        11 => 2,
        12 => 2,
        17 => 2,
        13 => 1
    },
    5 => {        # Friday
        12 => 2,
        13 => 1
    },
}

Schedule.delete_all

Schedule.find_or_create_by(course: c1, week: this_week, year: this_year) do |schedule|
    schedule.slots = slots
end

Schedule.find_or_create_by(course: c1, week: next_week, year: next_year) do |schedule|
    schedule.slots = slots
end

Appointment.delete_all

Appointment.find_or_create_by!(course: c1, slot: 1, hour: 9, day: 2, week: this_week, year: this_year) do |app|
    app.user = User.first
    app.subject = "Scratch"
end

Appointment.find_or_create_by!(course: c1, slot: 2, hour: 10, day: 2, week: next_week, year: next_year) do |app|
    app.user = User.first
    app.subject = "Scratch"
end
