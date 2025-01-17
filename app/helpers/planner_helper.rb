module PlannerHelper
    DAYS = ["Zondag", "Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag"]
    MONTHS = ["n/a", "januari", "februari", "maart", "april", "mei", "juni",
              "juli", "augustus", "september", "oktober", "november", "december"]

    def get_available_slots(course, year, week, day, slots, amount)
        all_selected = []
        result = []
        options = all_available_slots(course, year, week, day, slots)
        srand(current_user.id || 9393927)

        # skip if there are no options
        if options.count < 1 || amount <= 0
            return []
        end

        # if we need 2 suggestions or less, always get random options (must be at least 1,5 hour apart)
        if amount <= 2
            # get a random option
            selected = options.sample
            all_selected.push(selected)
            result.push(hour_slot_to_result(course, year, week, day, selected))

            # loop until we have all required options
            counter = 0
            until result.count == amount || counter == 100
                counter += 1

                # get another random option
                selected = options.sample

                # get time diff
                hdiff = (selected[0] - result[0]["hour"]).abs
                sdiff = (selected[1] - result[0]["slot"]).abs

                # check if it is at least 1,5 hour from the first selected option
                if (hdiff == 1 && sdiff > 2) || hdiff > 1
                    all_selected.push(selected)
                    result.push(hour_slot_to_result(course, year, week, day, selected))
                end
            end
        # if we need more than 2 options, always get the first, then 50% in the first half and 25% in the third and fourth quarter
        else
            # get the first
            result.push(hour_slot_to_result(course, year, week, day, options.first))
            all_selected.push(options.first)

            # run through until we have all the required options
            counter = 0
            until result.count == amount || counter == 100
                counter += 1

                # get a random option
                selected = select_candidates(amount, all_selected.count, options).sample

                # check that it is not already selected
                if !all_selected.include? selected
                    all_selected.push(selected)
                    result.push(hour_slot_to_result(course, year, week, day, selected))
                end
            end
        end

        return result.sort_by{|i| i["dt"]}
    end

    def all_available_slots(course, year, week, day, slots)
        bookings = course.appointments.booked_per_slot(year, week, day)
        options = []

        # run through the available hours
        slots.keys.each do |hour|
            # run through the available slots within the hour
            for i in 1..course.slots do
                # add if no bookings for the slot or less than available
                if !bookings[[hour,i]] || bookings[[hour,i]] < slots[hour]
                    options.push([hour, i])
                end
            end
        end

        return options
    end

    def select_candidates(amount, count, options)
        # make sure we're looking for options in the right segment of the day
        complete = count.to_f / amount.to_f

        if complete < 0.5
            return options.slice(0, (options.count / 2) - 1)
        end

        if complete < 0.75
            return options.slice(options.count / 2, (options.count / 4 * 3) - 1)
        end

        return options.slice(options.count / 4 * 3, options.count)
    end

    def hour_slot_to_result(course, year, week, day, slot)
        # convert to the format required for rendering the page
        dt = DateTime.commercial(
            year, week, day, slot[0], (slot[1]-1).to_f/course.slots*60, 0, '+2')
        return {"daytext" => daytext(dt),
                "date" => dt.to_date.mday.to_s + " " + MONTHS[dt.to_date.mon],
                "time" => dt.strftime("%H:%M"),
                "year" => year,
                "week" => week,
                "day" => day,
                "hour" => slot[0],
                "slot" => slot[1],
                "dt" => dt}
    end

    def daytext(dt)
        # return a human-friendly day name
        if dt.today?
            return "Vandaag"
        end

        if dt.to_date == Date.tomorrow
            return "Morgen"
        end

        return DAYS[dt.to_date.wday]
    end
end
