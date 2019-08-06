module CostAnalysis

  class TableWithGroupHeaders

    # header_rows and summary_rows are indices
    # into data that tell which rows are which
    attr_accessor :header_rows, :summary_rows, :data

    def initialize()
      @data = []
      @header_rows = []
      @summary_rows = []
    end

    def add_column_labels(row)
      @data << row
    end

    def add_header(row)
      @header_rows << @data.size
      @data << row
    end

    def add_data(row)
      @data << row
    end

    def concat(data_rows)
      @data.concat(data_rows)
    end

    def add_summary(row)
      @summary_rows << @data.size
      @data << row
    end

    def row_count
      @data.size
    end

    def table_rows
      @data
    end

    def combine_with(other)

      if other
        pad = self.data.size
        self.data += other.data
        self.header_rows += other.header_rows.map { |i| i + pad }
        self.summary_rows += other.summary_rows.map{ |i| i + pad }
      end
      self
    end

    def max_number_of_columns(rows)
      counts = []

      rows.each do |row|
        row_count = 0
        row.each do |col|
          if col.is_a?(Hash) && col.has_key?(:colspan)
            row_count += col[:colspan].to_i
          else
            row_count += 1
          end
        end
        counts << row_count
      end
      counts.max
    end
    # header_cols & data_cols are args?
    def split(keep:, cols:)

      max_cols = max_number_of_columns(self.data)
      table_count = (max_cols-keep)/cols
      table_count += 1 if (max_cols-keep) % cols > 0

      # Setup an array to hold the new tables
      # we need to create.
      # The header & summary indices stay the same since
      # we have the same number of rows.
      tables = []
      table_count.times do
        t = TableWithGroupHeaders.new
        t.header_rows = self.header_rows
        t.summary_rows = self.summary_rows
        tables << t
      end

      # Copy each row of data, one at a time
      self.data.each do |row|

        # If it's a row with a single full
        # width cell we can just add it and be done
        if full_span?(row)
          # single row we just resize the colspan
          tables.each do |table|
            colspan = [row.first[:colspan], keep+cols].min
            new_row = row.first.merge({:colspan => colspan})
            table.add_data [new_row]
          end
          next
        end

        keep_cols = []
        keep_count = 0
        data_cols = Array.new(table_count) { Array.new }
        data_count = 0

        # Copy each of the column
        row.each do |col|

          if keep_count < keep
            #
            # The header / keep columns go in every table
            #

            if col.is_a?(Hash) && col.has_key?(:colspan)
              keep_count += col[:colspan]
            else
              keep_count += 1
            end
            #we're keeping so add to each table
            #we'll copy header & summary indices later
            keep_cols << col
          else
            #
            # The data columns need to go to the correct table
            #

            #it's a data column so figure out
            #which table it goes in
            table_idx = data_count/cols
            data_cols[table_idx] << col
            data_count += 1
          end
        end


        # copy captured columns to the tables
        data_cols.each_with_index do |table_cols,table_idx|
          tables[table_idx].add_data keep_cols + table_cols
        end

      end

      #check the sizing of the program core
      #row on a table that might be too short and
      #fix it
      tables.each do |table|
        table.data.each do |r|

          if full_span?(r)
            r.first[:colspan] = max_number_of_columns(table.data.reject{ |it| full_span?(it) })
          end
        end
      end

      tables
    end
    
    # A row that only has a single cell spanning the whole table
    def full_span?(row)
      row.size == 1 && row.first.is_a?(Hash)
    end

    def to_s
      col_size = 10
      s = []
      s += printable_header_lines(col_size)
      s += printable_data_rows(col_size)
      s += printable_summary_rows(col_size)
      s.join("\n")
    end

    private

    #These all need return arrays of strings
    def printable_header_lines(col_size=10)
      s = []
      s << ("-" * 140)
      s << column_label_row.map{ |c| c.center(col_size) }.join
      s << core_label_row.map{ |c| c[:content]}.join(" ")
      s
    end

    def printable_data_rows(col_size=10)
      data_rows.map{ |c|
        row = ""
        row += c[0].rjust(col_size)
        row += c[1..-1].map{ |ic| ic.to_s.center(col_size) }.join
        row
      }
    end

    def printable_summary_rows(col_size=10)
      row = ""
      header = summary_row[0]
      row += header[:content].ljust(col_size*header[:colspan])
      summary_row[1..-1].each do |c|
        row += c.to_s.center(col_size)
      end
      [row]
    end

    def column_label_row
      data[0]
    end

    def core_label_row
      data[1]
    end

    def data_rows
      data[2..-2]
    end

    def summary_row
      data[-1]
    end

  end

end
