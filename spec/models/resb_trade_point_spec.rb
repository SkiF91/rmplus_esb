describe ResbTradePoint do
  describe '#detect_department' do
    def mock_dep_result(tt)
      dep = FactoryBot.build_stubbed(:user_department, name: tt.name)
      allow(UserDepartment).to receive(:where).with("name like ?", tt.name) { [dep] }
      dep
    end

    context 'when department_id.blank?' do
      context 'when new_record?' do
        subject(:tt) { FactoryBot.build(:resb_trade_point) }

        before(:example) do
          is_expected.to be_new_record
          expect(tt.department_id).to be_blank
          is_expected.not_to be_department_id_changed
        end

        it 'must detect fully equal' do
          FactoryBot.create(:user_department)
          dep = FactoryBot.create(:user_department, name: tt.name)
          FactoryBot.create(:user_department)

          expect { tt.send(:detect_department) }.to change { tt.department }.to eq(dep)
        end

        it 'must detect if department_id_changed?' do
          allow(tt).to receive(:department_id_changed?).and_return(true)
          is_expected.to be_department_id_changed

          dep = mock_dep_result(tt)
          expect { tt.send(:detect_department) }.to change { tt.department }.to eq(dep)
        end

        it 'must not detect' do
          FactoryBot.create_list(:user_department, 3)
          expect { tt.send(:detect_department) }.not_to change { tt.department }
        end

        it 'must not detect partial equal' do
          FactoryBot.create(:user_department)
          FactoryBot.create(:user_department, name: "#{tt.name}-salt")
          FactoryBot.create(:user_department)

          expect { tt.send(:detect_department) }.not_to change { tt.department }
        end
      end

      context 'when not department_id_changed?' do
        it 'must detect' do
          tt = FactoryBot.build_stubbed(:resb_trade_point)
          expect(tt).not_to be_new_record
          expect(tt.department_id).to be_blank
          expect(tt).not_to be_department_id_changed
          dep = mock_dep_result(tt)

          expect { tt.send(:detect_department) }.to change { tt.department }.to eq(dep)
        end
      end

      context 'when not new_record? and department_id_changed?' do
        it 'must not detect' do
          tt = FactoryBot.build_stubbed(:resb_trade_point)
          expect(tt).not_to be_new_record
          allow(tt).to receive(:department_id_changed?).and_return(true)
          expect(tt).to be_department_id_changed

          mock_dep_result(tt)

          expect { tt.send(:detect_department) }.not_to change { tt.department }
        end
      end
    end

    context 'when not department_id.blank?' do
      it 'must not detect' do
        tt = FactoryBot.build(:resb_trade_point, department_id: 777)
        expect(tt).to be_new_record
        mock_dep_result(tt)

        expect { tt.send(:detect_department) }.not_to change { tt.department }
      end
    end
  end
end