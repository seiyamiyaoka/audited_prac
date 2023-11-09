require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should have_many(:tasks).dependent(:destroy) }
  it { should have_many(:task_assigns).dependent(:destroy) }
  it { should have_many(:assigned_tasks).through(:task_assigns).source(:task) }

  describe 'auditing' do
    let(:user) {
      create(:user, name: 'test')
    }

    before do
      user
    end

    it 'basic test' do
      expect(user.audits.count).to eq(1)
      user.update(name: 'test2')
      expect(user.audits.count).to eq(2)
      user.destroy
      expect(user.audits.count).to eq(3)
    end

    it 'auditの内容を確認' do
      # user.audits.classはAudit::ActiveRecord_Associations_CollectionProxy
      user.update(name: 'test2')
      audit = user.audits.last.revision
      expect(user.audits.last.class).to eq(Audited::Audit)
      # Auditインスタンスはpolymorphicなので、auditable_typeとauditable_idでauditableを特定できる

      expect(audit.class).to eq(User)
      binding.irb
    end

    describe 'associated task' do
      let(:task) {
        create(:task, user: user)
      }

      before do
        task
      end

      it 'auditの内容を確認' do
        user.update(name: 'user2')
        audit = user.audits.last.revision
        expect(audit.class).to eq(User)
        expect(audit.tasks.count).to eq(1)

        expect(audit.tasks.first.class).to eq(Task)
        expect(audit.tasks.first.name).to eq(task.name)

        # ここで変更をしても、auditには反映されない(taskにはauditedをincludeしていないから)
        # taskをけしたら復元不可能
        task.update(name: 'task2')

        audit = user.audits.last.revision

      end

      it 'taskにauditedをincludeすると、auditに反映される' do
        task.update(name: 'task2')
        audit = user.audits.last.revision
        expect(audit.class).to eq(User)
        expect(audit.tasks.count).to eq(1)

        expect(audit.tasks.first.class).to eq(Task)
        expect(audit.tasks.first.name).to eq(task.name)
        # taskにauditedをincludeすると、auditに反映される
        # expect(audit.tasks.first.audits.first.revision).to eq task
        binding.irb
        # has_associated_auditsをincludeすると、user.associated_auditsでtaskのauditを取得できる
        # belongs_to側にもaudited associated_with: :userを追加する必要がある
        #<Audited::Audit:0x00000001110d4ed8
          # id: 3,
          # auditable_id: 1,
          # auditable_type: "Task",
          # associated_id: 1,
          # associated_type: "User",
          # user_id: nil,
          # user_type: nil,
          # username: nil,
          # action: "update",
          # audited_changes: {"name"=>["野良仕事", "task2"]},
          # version: 2,
          # comment: nil,
          # remote_address: nil,
          # request_uuid: "6b2f5a53-a347-484e-9594-1867cbee108a",
          # created_at: Thu, 09 Nov 2023 06:39:11.330942000 UTC +00:00>]
        # taskのauditにuserがassociatedされている
        # "SELECT \"audits\".* FROM \"audits\" WHERE \"audits\".\"associated_id\" = 1 AND \"audits\".\"associated_type\" = 'User'"
        expect(user.associated_audits).to eq(audit.tasks.first.audits)
      end

      it 'userのnameをrevision 1のnameに変更する' do
        user.update(name: 'user2')
        audit = user.audits.last.revision
        expect(audit.class).to eq(User)
        expect(audit.tasks.count).to eq(1)

        expect(audit.tasks.first.class).to eq(Task)
        expect(audit.tasks.first.name).to eq(task.name)

        # userのnameをrevision 1のnameに変更する
        user.update(name: user.audits.first.revision.name)
        audit = user.audits.last.revision
        expect(audit.class).to eq(User)
        expect(audit.tasks.count).to eq(1)

        expect(audit.tasks.first.class).to eq(Task)
        expect(audit.tasks.first.name).to eq(task.name)
      end
    end
  end
end
