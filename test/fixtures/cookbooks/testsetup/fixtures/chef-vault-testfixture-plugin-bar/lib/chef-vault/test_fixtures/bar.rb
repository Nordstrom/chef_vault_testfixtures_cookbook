class ChefVault
  class TestFixtures
    class Bar
      def test
        { 'bar' => 1 }
      end

      alias_method :prod, :test
    end
  end
end
