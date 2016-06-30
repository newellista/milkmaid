require "google/api_client"
require "google_drive"

module MilkMaid
  TIMESTAMP_COL = 1
  READING_COL = 2
  DATA_COL = 3

  class SpreadsheetWriter
    def self.write_spreadsheet(session_file, spreadsheet_name, record)
      session = GoogleDrive.saved_session(session_file)

      puts "Creating Spreadsheet #{spreadsheet_name}"
      sheet = session.create_spreadsheet(spreadsheet_name)

      print_record(sheet, record)
    end

    def self.print_footer(ws, row, record)
      ws[row, 1] = "Batch Name"
      ws[row, 2] = record.name
      row += 1
      ws[row, 1] = "Duration"
      ws[row, 2] = record.duration
      row += 1
      ws[row, 1] = "Base Temperature"
      ws[row, 2] = record.base_temperature
      row += 1
      ws[row, 1] = "Status"
      ws[row, 2] = record.status
      ws.save
    end

    def self.print_record(sheet, record)
      worksheet_name = "#{record.name}: #{record.status}"
      puts "Creating worksheet for #{worksheet_name}"
      ws = sheet.add_worksheet(worksheet_name)

      ws[1,TIMESTAMP_COL] = "Timestamp"
      ws[1,READING_COL] = "Reading"
      ws[1,DATA_COL] = "Value"

      row = 2

      record.events.each do |event|
        ws[row, TIMESTAMP_COL] = event.timestamp
        ws[row, READING_COL] = event.name
        ws[row, DATA_COL] = event.data unless event.data == 0
        row += 1
      end

      print_footer(ws, row + 1, record)
    end
  end
end
